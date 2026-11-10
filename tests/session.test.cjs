const {test}=require("node:test");
const assert=require("node:assert/strict");
const {Session,validateFile,toBase64,unwrap}=require("../src/igAttachments.js");
const cfg={accept:".pdf,.png,.txt",maxBytes:100000,maxCount:3};
function harness({failChunk=false,readOnly=false}={}){
 const calls=[],state={token:"T",parts:[],received:0,files:[],commits:[]};let failed=false;
 const adapter={
  setToken(ctx,token){state.commits.push({key:ctx.key,record:ctx.record,token});},
  clearToken(ctx){state.clears=(state.clears||0)+1;},
  async request(op,data){
   calls.push({op,...data});
   if(op==="OPEN")return {ok:true,token:"T",files:[]};
   if(op==="LIST")return {ok:true,files:state.files};
   if(op==="START"){state.files=[{id:"F",size:data.size,ready:false,staged:true}];return {ok:true,uploadId:"F"};}
   if(op==="PUT"){state.puts=(state.puts||0)+1;state.files=[...state.files.filter(x=>x.id!=="P"+state.puts),{id:"P"+state.puts,size:data.size,ready:true,staged:true}];return {ok:true,files:state.files};}
   if(op==="CHUNK"){
    const raw=Buffer.from(data.chunks.join(""),"base64");
    if(data.offset===state.received){state.parts.push(raw);state.received+=raw.length;}
    if(failChunk&&!failed){failed=true;throw new Error("Connection lost after the server stored this chunk");}
    return {ok:true,received:state.received};
   }
   if(op==="FINISH"){state.files[0].ready=true;return {ok:true,files:state.files};}
   if(op==="REMOVE"){state.files=state.files.filter(x=>x.id!==data.id);return {ok:true,files:state.files};}
   throw new Error(op);
  }
 };
 return {session:new Session({...cfg,maxBytes:1000000},adapter),state,calls};
}
function file(size=60000){const b=new Blob([Buffer.alloc(size,101)]);b.name="receipt.txt";return b;}
test("chunk retry sends identical offset and bytes; data is not duplicated",async()=>{
 const {session,state,calls}=harness({failChunk:true});await session.open({key:null,record:"new"});
 await session.upload([file(450000)]);
 assert.equal(state.received,450000);assert.equal(Buffer.concat(state.parts).length,450000);
 const chunks=calls.filter(x=>x.op==="CHUNK");
 assert.equal(chunks[0].offset,chunks[1].offset);assert.deepEqual(chunks[0].chunks,chunks[1].chunks);
 assert.ok(chunks.every(x=>x.chunks.every(c=>c.length<=8000&&c.length%4===0)));
 assert.equal(session.canSave(),true);
});
test("async token assignment is bound to the captured record, not a later active row",async()=>{
 const {session,state}=harness();const context={key:"A",record:"row A"};
 const promise=session.open(context);context.key="B";context.record="row B";await promise;
 await session.upload([file(10)]);session.settle();
 assert.deepEqual(state.commits,[{key:"A",record:"row A",token:"T"}]);
});
test("opening and closing without changes leaves the row untouched",async()=>{
 const {session,state}=harness();await session.open({key:"A",record:"row A"});
 assert.deepEqual(state.commits,[]);
 session.settle();assert.deepEqual(state.commits,[]);
 await session.upload([file(10)]);await session.upload([file(10)]);
 assert.equal(state.commits.length,0,"no grid update while the panel is open");
 session.settle();assert.equal(state.commits.length,1);
});
test("failed upload leaves incomplete file visible and prevents save until removed",async()=>{
 const {session}=harness();await session.open({key:"A"});
 const original=session.adapter.request;
 session.adapter.request=async(op,data)=>{if(op==="CHUNK")throw new Error("Offline");return original(op,data);};
 await assert.rejects(session.upload([file(450000)]),/Offline/);
 assert.equal(session.busy,false);assert.equal(session.files.length,1);assert.equal(session.canSave(),false);
 await session.remove(session.files[0]);assert.equal(session.canSave(),true);
});
test("an incomplete upload alone keeps the row pending, so the save reaches finalize_edit (which refuses it)",async()=>{
 const {session,state}=harness();await session.open({key:"A",record:"row A"});
 const original=session.adapter.request;
 session.adapter.request=async(op,data)=>{if(op==="CHUNK")throw new Error("Offline");return original(op,data);};
 await assert.rejects(session.upload([file(450000)]),/Offline/);
 session.settle();
 assert.equal(state.commits.length,1,"the row holds the token");
 // removing the incomplete file is the way out: nothing pending, the token goes again
 await session.remove(session.files[0]);session.settle();
 assert.equal(state.clears,1);
});
test("read-only opens LIST and rejects mutations",async()=>{
 const {session,calls}=harness();await session.open({key:"A",readOnly:true});
 assert.equal(calls[0].op,"LIST");
 await assert.rejects(session.upload([file()]),/read only/);
 await assert.rejects(session.remove({id:"F"}),/read only/);
});
test("unsupported, empty, and oversized files are rejected before upload",()=>{
 assert.throws(()=>validateFile({name:"a.svg",size:1},cfg),/file type is not allowed/);
 assert.throws(()=>validateFile({name:"a.txt",size:0},cfg),/is empty/);
 assert.throws(()=>validateFile({name:"a.txt",size:100001},cfg),/larger than the 97.7 KB limit/);
 assert.doesNotThrow(()=>validateFile({name:"A.PDF",size:10},cfg));
});
test("file count excludes staged removals",async()=>{
 const {session}=harness();await session.open({key:"A"});
 session.files=[{id:"old",removed:true}];await session.upload([file(10)]);
 assert.equal(session.files[0].ready,true);
});
test("parallel operations cannot mutate the same session",async()=>{
 const {session}=harness();await session.open({key:"A"});
 let release;session.adapter.request=()=>new Promise(r=>{release=r;});
 const operation=session.remove({id:"F"});
 await assert.rejects(session.remove({id:"X"}),/Please wait/);
 // Resolve both REMOVE and LIST.
 release({ok:true});await new Promise(r=>setImmediate(r));release({ok:true,files:[]});await operation;
 assert.equal(session.busy,false);
});
test("base64 preserves arbitrary binary bytes",()=>{
 const source=Uint8Array.from({length:256},(_,i)=>i);
 assert.deepEqual(Buffer.from(toBase64(source.buffer),"base64"),Buffer.from(source));
 assert.equal(unwrap({v:"id",d:"Name"}),"id");
});


test("failed open cannot expose the preceding row's files or accept mutations",async()=>{
 const {session}=harness();await session.open({key:"A"});session.files=[{id:"secret",ready:true}];
 session.adapter.request=async()=>({ok:false,error:"Access denied"});
 await assert.rejects(session.open({key:"B"}),/Access denied/);
 assert.deepEqual(session.files,[]);assert.equal(session.canSave(),false);
 await assert.rejects(session.upload([file(10)]),/Reopen/);
});

test("a small file is one request",async()=>{
 const {session,calls}=harness();await session.open({key:"A"});calls.length=0;
 await session.upload([file(1000)]);
 assert.deepEqual(calls.map(c=>c.op),["PUT"]);
});
test("adding a file and removing it again leaves the row as it was",async()=>{
 const {session,state}=harness();await session.open({key:null,record:"new"});
 await session.upload([file(10)]);session.settle();assert.equal(state.commits.length,1);
 await session.remove(session.files[0]);session.settle();
 assert.equal(state.clears,1);assert.equal(session.claimed,false);
 // within one panel visit: add and remove before closing never touches the row
 await session.upload([file(10)]);await session.remove(session.files[0]);session.settle();
 assert.equal(state.commits.length,1);
});

test("extra fields: defaults go with new files, saved-file changes are pending, required fields block",async()=>{
 const {session,state,calls}=harness();
 session.cfg={...session.cfg,fields:[{n:1,kind:"TEXT",label:"Document Type",required:true},{n:2,kind:"HIDDEN",label:"Category"}]};
 // a saved file without changes
 state.files=[{id:"S",name:"old.pdf",ready:true,staged:false,values:["INV",""]}];
 const original=session.adapter.request;
 session.adapter.request=async(op,data)=>{
  if(op==="OPEN")return {ok:true,token:"T",files:state.files};
  if(op==="FIELDS"){state.files=state.files.map(x=>x.id===data.id?{...x,values:data.values,changed:!x.staged}:x);return {ok:true,files:state.files};}
  if(op==="PUT"){state.files=[...state.files,{id:"N",name:"new.txt",ready:true,staged:true,values:data.values}];return {ok:true,files:state.files};}
  return original(op,data);
 };
 await session.open({key:"A",defaults:["RCP","TRAVEL"]});
 assert.deepEqual(session.defaults,["RCP","TRAVEL",""]);
 await session.upload([file(10)]);
 assert.deepEqual(calls.length,0);
 assert.deepEqual(state.files[1].values,["RCP","TRAVEL",""]);
 // clearing a required field of the new file is reported
 await session.setFields(state.files[1],["","x",""]);
 assert.deepEqual(session.missing(),["Document Type for new.txt"]);
 // a change of a saved file makes the row pending
 await session.setFields(state.files[1],["INV","x",""]);
 assert.deepEqual(session.missing(),[]);
 await session.setFields(state.files[0],["RCP","note",""]);
 session.settle();
 assert.equal(state.commits.length,1);
});

test("one refused file does not stop the others; the problems are reported together",async()=>{
 const {session,calls}=harness();await session.open({key:"A"});calls.length=0;
 const bad=file(10);bad.name="tool.exe";
 await assert.rejects(session.upload([file(10),bad,file(10)]),/tool\.exe: this file type is not allowed/);
 assert.equal(calls.filter(c=>c.op==="PUT").length,2);
});
test("a user who may only read gets the files read only",async()=>{
 const {session}=harness();
 session.adapter.request=async(op)=>op==="OPEN"?{ok:true,readOnly:true,files:[{id:"S",name:"a.pdf",ready:true}]}:{ok:true,files:[]};
 await session.open({key:"A"});
 assert.equal(session.context.readOnly,true);assert.equal(session.token,"");
 await assert.rejects(session.upload([file(10)]),/read only/);
});
test("a field change waits for a running upload and keeps the other field's new value",async()=>{
 const {session,state}=harness();
 session.cfg={...session.cfg,fields:[{n:1,kind:"TEXT",label:"A"},{n:2,kind:"TEXT",label:"B"}]};
 state.files=[{id:"S",name:"a.pdf",ready:true,staged:false,values:["a","b"]}];
 const sent=[];const original=session.adapter.request;let release;
 session.adapter.request=async(op,data)=>{
  if(op==="OPEN")return {ok:true,token:"T",files:state.files};
  if(op==="PUT"){await new Promise(r=>{release=r;});return original(op,data);}
  if(op==="FIELDS"){sent.push(data.values);state.files=state.files.map(x=>x.id===data.id?{...x,values:data.values,changed:true}:x);return {ok:true,files:state.files};}
  return original(op,data);
 };
 await session.open({key:"A"});
 const upload=session.upload([file(10)]);
 const f1=session.setField(state.files[0],0,"new a");   // while the upload runs: waits, no "Please wait"
 const f2=session.setField(state.files[0],1,"new b");
 assert.equal(session.fieldValue(state.files[0],0),"new a","the draft shows at once");
 while(!release)await new Promise(r=>setImmediate(r));
 release();await upload;await f1;await f2;await session.idle();
 assert.deepEqual(sent,[["new a","new b",""]],"one request with both values");
 assert.equal(session.hasDrafts(),false);
});
test("a refused field change stays a draft; putting the old value back needs no request",async()=>{
 const {session,state}=harness();
 session.cfg={...session.cfg,fields:[{n:1,kind:"TEXT",label:"A"}]};
 state.files=[{id:"S",name:"a.pdf",ready:true,staged:false,values:["a"]}];
 let fields=0;
 session.adapter.request=async op=>{
  if(op==="FIELDS"){fields++;return {ok:false,reason:"too long"};}
  return {ok:true,token:"T",files:state.files};
 };
 await session.open({key:"A"});
 await assert.rejects(session.setField(state.files[0],0,"x".repeat(10)),/too long/);
 assert.equal(session.fieldValue(state.files[0],0),"x".repeat(10));assert.equal(session.hasDrafts(),true);
 await assert.rejects(session.flushFields(),/too long/);assert.equal(fields,2);
 assert.equal(await session.setField(state.files[0],0,"a"),false);
 assert.equal(fields,2);assert.equal(session.hasDrafts(),false);
});
test("a small file stored by the server whose reply was lost is shown (list re-read)",async()=>{
 const {session,state,calls}=harness();await session.open({key:"A",record:"row A"});
 session.adapter.request=async(op,data)=>{
  calls.push({op});
  if(op==="PUT"){state.files=[{id:"P",name:data.name,size:data.size,ready:true,staged:true}];throw new Error("Attachment request failed.");}
  return {ok:true,files:state.files};
 };
 await assert.rejects(session.upload([file(10)]),/request failed/);
 assert.deepEqual(calls.slice(-2).map(c=>c.op),["PUT","LIST"]);
 assert.equal(session.files.length,1,"the stored file is visible");
 session.settle();assert.equal(state.commits.length,1,"the row holds the token");
});
test("a file refused in the browser needs no list",async()=>{
 const {session,calls}=harness();await session.open({key:"A"});calls.length=0;
 const bad=file(10);bad.name="tool.exe";
 await assert.rejects(session.upload([bad]),/not allowed/);
 assert.deepEqual(calls,[]);
});
test("the read-only fallback drops an old token of the row",async()=>{
 const {session}=harness();
 session.adapter.request=async()=>({ok:true,readOnly:true,files:[]});
 await session.open({key:"A",token:"0123456789ABCDEF0123456789ABCDEF"});
 assert.equal(session.context.readOnly,true);assert.equal(session.token,"");
});
test("the panel's own empty edit is sent again (reuse), the row does not hold it",async()=>{
 const {session,state,calls}=harness();const own="0123456789ABCDEF0123456789ABCDEF";
 session.adapter.request=async(op,data)=>{calls.push({op,...data});return op==="OPEN"?{ok:true,token:own,files:[]}:{ok:true,files:[{id:"P",ready:true,staged:true}]};};
 await session.open({key:"A",record:"row A",token:"",reuse:own});
 assert.equal(calls[0].token,own,"presented to the server");
 assert.equal(session.claimed,false,"not on the row");
 session.settle();assert.equal(state.commits.length,0,"nothing pending: the row stays untouched");
 await session.upload([file(10)]);session.settle();
 assert.deepEqual(state.commits.map(c=>c.token),[own],"claimed once something is pending");
});
test("cancel stops a large upload between its parts and removes the stored part",async()=>{
 const {session,state,calls}=harness();await session.open({key:"A"});
 const original=session.adapter.request;
 session.adapter.request=async(op,data)=>{const r=await original(op,data);if(op==="CHUNK")session.cancel();if(op==="REMOVE")state.files=[];return r;};
 await assert.rejects(session.upload([file(450000)]),/receipt\.txt: upload cancelled/);
 const ops=calls.map(c=>c.op);
 assert.equal(ops.filter(o=>o==="CHUNK").length,1,"no part after the cancel");
 assert.ok(ops.includes("REMOVE"),"the stored part is removed");assert.ok(!ops.includes("FINISH"));
 assert.equal(session.files.length,0);assert.equal(session.busy,false);
});
test("cancel skips the files not sent yet",async()=>{
 const {session,calls}=harness();await session.open({key:"A"});calls.length=0;
 const original=session.adapter.request;
 session.adapter.request=async(op,data)=>{const r=await original(op,data);if(op==="PUT")session.cancel();return r;};
 await assert.rejects(session.upload([file(10),file(10),file(10)]),/^Error: Upload cancelled\.$/);
 assert.equal(calls.filter(c=>c.op==="PUT").length,1,"the running small file finishes, the others are not sent");
 assert.equal(session.cancelled,false,"the next upload starts normally");
});
test("a file count in the column is not an edit token",async()=>{
 const {session,calls}=harness();await session.open({key:"A",token:"3"});
 assert.equal(calls[0].token,"");
});
