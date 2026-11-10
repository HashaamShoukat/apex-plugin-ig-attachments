// Regressions of the review of 2026-11-05 (qa/review-2026-11-05/probes.cjs), in Chrome with the real
// panel and init code and test doubles for the server and the grid:
//   4 - Escape while a field still has the focus: the value is saved before the panel closes
//   5 - two attachment columns in one grid: a click opens only the clicked column's panel
//   5 - the grid's Save guard is shared by both columns and removed with the last, in any order
// Needs playwright-core and Chrome (CHROME = path to chrome.exe, or the installed Chrome channel).
const {chromium}=require("playwright-core");
const {pathToFileURL}=require("node:url");
const path=require("node:path"),assert=require("node:assert/strict");
(async()=>{
 const browser=await chromium.launch(process.env.CHROME?{executablePath:process.env.CHROME,headless:true}:{channel:"chrome",headless:true});
 try {
  const page=await browser.newPage();
  const errors=[];page.on("pageerror",e=>errors.push(e.message));
  await page.goto(pathToFileURL(path.resolve("demo/index.html")).href);

  // ---- 4: Escape with the field still focused, slow server
  await page.evaluate(async()=>{
   const token="0123456789ABCDEF0123456789ABCDEF";
   window.t4={calls:[],claims:0,files:[{id:"saved1",name:"receipt.txt",mime:"application/octet-stream",size:1,ready:true,staged:false,changed:false,values:["old"]}]};
   const cfg={item:"T4",accept:".txt",maxBytes:1000,maxCount:3,fields:[{n:1,kind:"TEXT",label:"Remark",required:false}]};
   const adapter={setToken(){t4.claims++;},async request(op,data){
    t4.calls.push(op);
    if(op==="FIELDS"){await new Promise(r=>setTimeout(r,300));t4.files=t4.files.map(f=>({...f,values:data.values,changed:true}));}
    return {ok:true,token,files:t4.files};
   }};
   const session=new igaAttachments.Session(cfg,adapter);
   window.t4panel=igaAttachments.createPanel(cfg,session,{onclose(){session.settle();t4.settledWith=t4.calls.slice();}});
   await t4panel.open({key:"1",token:"",readOnly:false,label:""});
  });
  await page.locator("#T4_PANEL .iga-field input").fill("typed, not blurred");
  await page.keyboard.press("Escape");
  await page.waitForFunction(()=>!t4panel.dialog.open,null,{timeout:5000});
  const r4=await page.evaluate(()=>({calls:t4.calls,settledWith:t4.settledWith,claims:t4.claims,value:t4.files[0].values[0]}));
  assert.deepEqual(r4.calls,["OPEN","FIELDS"],"one FIELDS request");
  assert.deepEqual(r4.settledWith,["OPEN","FIELDS"],"settled after the field was saved");
  assert.equal(r4.claims,1,"the row holds the token");
  assert.equal(r4.value,"typed, not blurred");

  // a failing field save keeps the panel open
  await page.evaluate(async()=>{
   t4panel.destroy();
   const cfg={item:"T4B",accept:".txt",maxBytes:1000,maxCount:3,fields:[{n:1,kind:"TEXT",label:"Remark",required:false}]};
   const files=[{id:"s",name:"a.txt",mime:"text/plain",size:1,ready:true,staged:false,changed:false,values:["x"]}];
   const adapter={setToken(){},async request(op){if(op==="FIELDS")return {ok:false,reason:"Remark is too long."};return {ok:true,token:"0123456789ABCDEF0123456789ABCDEF",files};}};
   const session=new igaAttachments.Session(cfg,adapter);
   window.t4b=igaAttachments.createPanel(cfg,session,{onclose(){}});
   await t4b.open({key:"1",token:"",readOnly:false,label:""});
  });
  await page.locator("#T4B_PANEL .iga-field input").fill("too long");
  await page.keyboard.press("Escape");
  await page.waitForTimeout(400);
  assert.equal(await page.evaluate(()=>t4b.dialog.open),true,"stays open when the field could not be saved");
  assert.match(await page.locator("#T4B_PANEL .iga-message").textContent(),/too long/);
  // the refused text stays in the field (not the old value) and closing again retries, still open
  assert.equal(await page.locator("#T4B_PANEL .iga-field input").inputValue(),"too long","the typed text is kept");
  await page.keyboard.press("Escape");await page.waitForTimeout(300);
  assert.equal(await page.evaluate(()=>t4b.dialog.open),true,"a value the server still refuses is not dropped silently");
  // putting the shown value back is the way out: nothing to send, the panel closes
  await page.locator("#T4B_PANEL .iga-field input").fill("x");
  await page.locator("#T4B_PANEL .iga-done").click();
  await page.waitForFunction(()=>!t4b.dialog.open,null,{timeout:3000});
  await page.evaluate(()=>t4b.destroy());

  // ---- field drafts (recheck 2026-11-05 A/B and the field typed during an upload)
  const T="0123456789ABCDEF0123456789ABCDEF";
  // A: two fields typed quickly - the second request must not restore the first field
  await page.evaluate(async T=>{
   window.fa={calls:[],files:[{id:"f",name:"a.txt",mime:"text/plain",size:1,ready:true,staged:false,changed:false,values:["old A","old B"]}]};
   const cfg={item:"FA",accept:".txt",maxBytes:1000,maxCount:3,fields:[{n:1,kind:"TEXT",label:"A"},{n:2,kind:"TEXT",label:"B"}]};
   const session=new igaAttachments.Session(cfg,{setToken(){},async request(op,data){
    fa.calls.push(op);
    if(op==="FIELDS"){await new Promise(r=>setTimeout(r,300));fa.files=fa.files.map(f=>({...f,changed:true,values:data.values.slice()}));}
    return {ok:true,token:T,files:fa.files};
   }});
   window.faPanel=igaAttachments.createPanel(cfg,session,{});await faPanel.open({key:"1",token:""});
  },T);
  const fields=page.locator("#FA_PANEL .iga-field input");
  await fields.nth(0).fill("new A");await fields.nth(1).focus();await fields.nth(1).fill("new B");await fields.nth(0).focus();
  await page.waitForTimeout(1000);
  const ra=await page.evaluate(()=>({values:fa.files[0].values,message:document.querySelector("#FA_PANEL .iga-message").textContent}));
  assert.deepEqual(ra.values,["new A","new B",""],"both fields are saved");
  assert.equal(ra.message,"","no 'Please wait' refusal");
  await page.evaluate(()=>faPanel.destroy());

  // a field typed while an upload is running is sent after it; text typed (no change event yet) when
  // the upload finishes survives the redraw and is saved on Done
  await page.evaluate(async T=>{
   window.fu={calls:[],files:[{id:"f",name:"a.txt",mime:"text/plain",size:1,ready:true,staged:false,changed:false,values:["original"]},
    {id:"g",name:"b.txt",mime:"text/plain",size:1,ready:true,staged:false,changed:false,values:["second"]}]};
   const cfg={item:"FU",accept:".txt",maxBytes:100000,maxCount:5,fields:[{n:1,kind:"TEXT",label:"Remark"}]};
   const session=new igaAttachments.Session(cfg,{setToken(){fu.claimed=true;},async request(op,data){
    fu.calls.push(op+(data.values?":"+data.values[0]:""));
    if(op==="PUT"){await new Promise(r=>setTimeout(r,600));fu.files=fu.files.concat([{id:"u",name:data.name,mime:"text/plain",size:data.size,ready:true,staged:true,values:["","",""]}]);}
    if(op==="FIELDS")fu.files=fu.files.map(f=>f.id===data.id?{...f,changed:true,values:data.values.slice()}:f);
    return {ok:true,token:T,files:fu.files};
   }});
   window.fuSession=session;
   window.fuPanel=igaAttachments.createPanel(cfg,session,{onclose(){session.settle();fu.closed=true;}});await fuPanel.open({key:"1",token:""});
   session.upload([new File(["hello"],"c.txt")]).catch(()=>{});
  },T);
  await page.waitForTimeout(100);
  const first=page.locator("#FU_PANEL .iga-field input").nth(0),second=page.locator("#FU_PANEL .iga-field input").nth(1);
  await first.fill("typed during upload");await first.press("Tab");
  await second.fill("still typing");                       // focused, no change event, upload still running
  await page.waitForFunction(()=>!fuSession.busy&&document.querySelectorAll("#FU_PANEL .iga-file").length===3,null,{timeout:5000});
  assert.equal(await second.inputValue(),"still typing","typed text survives the redraw");
  await page.locator("#FU_PANEL .iga-done").click();
  await page.waitForFunction(()=>fu.closed,null,{timeout:5000});   // the close event comes in a later task
  const ru=await page.evaluate(()=>({values:fu.files.map(f=>f.values[0]),calls:fu.calls,claimed:!!fu.claimed}));
  assert.deepEqual(ru.values,["typed during upload","still typing",""],"both fields saved, the upload too");
  assert.deepEqual(ru.calls,["OPEN","PUT:","FIELDS:typed during upload","FIELDS:still typing"],"one request per change");
  assert.equal(ru.claimed,true,"the row holds the token");
  await page.evaluate(()=>fuPanel.destroy());

  // a field change that failed once (lost connection) is sent again when the panel closes
  await page.evaluate(async T=>{
   window.fr={calls:0,files:[{id:"f",name:"a.txt",mime:"text/plain",size:1,ready:true,staged:false,changed:false,values:["old"]}]};
   const cfg={item:"FR",accept:".txt",maxBytes:1000,maxCount:3,fields:[{n:1,kind:"TEXT",label:"Remark"}]};
   const session=new igaAttachments.Session(cfg,{setToken(){},async request(op,data){
    if(op==="FIELDS"){if(++fr.calls===1)throw new Error("Attachment request failed.");fr.files=fr.files.map(f=>({...f,changed:true,values:data.values.slice()}));}
    return {ok:true,token:T,files:fr.files};
   }});
   window.frPanel=igaAttachments.createPanel(cfg,session,{});await frPanel.open({key:"1",token:""});
  },T);
  await page.locator("#FR_PANEL .iga-field input").fill("new");await page.locator("#FR_PANEL .iga-field input").press("Tab");
  await page.waitForTimeout(200);
  assert.equal(await page.locator("#FR_PANEL .iga-field input").inputValue(),"new","kept after the failure");
  await page.locator("#FR_PANEL .iga-done").click();
  await page.waitForFunction(()=>!frPanel.dialog.open,null,{timeout:3000});
  assert.deepEqual(await page.evaluate(()=>[fr.calls,fr.files[0].values[0]]),[2,"new"],"retried once on close");
  await page.evaluate(()=>frPanel.destroy());

  // ---- 5: two columns in one grid
  const r5=await page.evaluate(async()=>{
   const token="0123456789ABCDEF0123456789ABCDEF";
   const grid=document.createElement("div");grid.id="RGRID";
   grid.innerHTML='<table><tbody><tr data-id="1"><td id="CELL_A"></td><td id="CELL_B"></td></tr></tbody></table>';
   document.body.append(grid);
   for(const id of ["COL_A","COL_B"]){
    const input=document.createElement("input");input.id=id;grid.append(input);
    const button=document.createElement("button");button.id=id+"_OPEN";grid.append(button);
   }
   const handlers=[],requests=[],row={ID:"1",A:"",B:""};
   const model={getOption:n=>n==="identityField"?["ID"]:n==="fields"?{ID:{},A:{elementId:"COL_A"},B:{elementId:"COL_B"}}:null,
    getRecord:()=>row,getRecordId:()=>"1",getRecordMetadata:()=>({}),getValue:(r,c)=>r[c],allowEdit:()=>true,
    setValue(r,c,v){r[c]=v;return "SET";},subscribe(){return "s";},unSubscribe(){}};
   const saved=[];const original=function(){saved.push("saved");};
   const action={action:original},actions={lookup:()=>action};
   const view={model,view$:{0:grid,grid(method){if(method==="getColumns")return [];if(method==="inEditMode")return false;if(method==="getActiveRecord")return row;}}};
   const jq=()=>({off(){return this;},on(name,selector,fn){if(selector===".iga-cell")handlers.push(fn);return this;}});
   const impls={};
   const item=()=>({});item.create=(id,impl)=>{impls[id]=impl;};
   window.apex={jQuery:jq,item,region:()=>({call(method){return method==="getViews"?view:actions;}}),
    event:{trigger(){}},message:{alert(m){saved.push("alert: "+m);}},util:{escapeHTML:s=>String(s)},
    server:{async plugin(id,data){requests.push({id,op:data.x01});return {ok:true,token,files:[]};}}};
   const cols=["COL_A","COL_B"].map(id=>igaAttachments.init({item:id,region:"RGRID",ajax:id,accept:".txt",maxBytes:1000,maxCount:3}));
   // the cells as the grid renders them: each column's displayValueFor
   document.getElementById("CELL_A").innerHTML=impls.COL_A.displayValueFor("2");
   document.getElementById("CELL_B").innerHTML=impls.COL_B.displayValueFor("");
   const target=document.querySelector("#CELL_A .iga-cell .iga-cell-label");
   handlers.forEach(fn=>fn({target}));
   await new Promise(r=>setTimeout(r,150));
   const open=[...document.querySelectorAll("dialog[open]")].map(d=>d.id);
   // Save guard: blocked while A is open; then destroy A first, B second -> the original is back
   action.action();
   const whileOpen=saved.slice();
   document.getElementById("COL_A_PANEL").close();
   const guardedAfterOpen=action.action!==original;
   cols[0].destroy();
   const stillGuarded=action.action!==original;
   action.action();
   cols[1].destroy();
   const restored=action.action===original;
   grid.remove();delete window.apex;
   return {handlers:handlers.length,open,requests,whileOpen,guardedAfterOpen,stillGuarded,restored,saved};
  });
  assert.equal(r5.handlers,2);
  assert.deepEqual(r5.open,["COL_A_PANEL"],"only the clicked column's panel opens");
  assert.deepEqual(r5.requests,[{id:"COL_A",op:"OPEN"}]);
  assert.ok(r5.whileOpen.some(x=>x.startsWith("alert:")),"save blocked while a panel is open");
  assert.ok(r5.guardedAfterOpen&&r5.stillGuarded,"the guard stays while one column remains");
  assert.ok(r5.saved.includes("saved"),"save runs once no panel is open");
  assert.ok(r5.restored,"the original Save action is back after the last column");

  // ---- a token pasted / filled into another row is undone; reopening sends the panel's own empty edit
  const r6=await page.evaluate(async()=>{
   const own="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",foreign="BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
   const grid=document.createElement("div");grid.id="RGRID6";
   grid.innerHTML='<table><tbody><tr data-id="1"><td></td></tr><tr data-id="2"><td></td></tr></tbody></table>';
   document.body.append(grid);
   const input=document.createElement("input");input.id="COL_P";grid.append(input);
   const button=document.createElement("button");button.id="COL_P_OPEN";grid.append(button);
   const rows={"1":{ID:"1",P:"2"},"2":{ID:"2",P:""}},subs=[],requests=[];let active=rows["1"];
   const model={getOption:n=>n==="identityField"?["ID"]:n==="fields"?{ID:{},P:{elementId:"COL_P"}}:null,
    getRecord:id=>rows[id],getRecordId:r=>r.ID,getRecordMetadata:()=>({}),getValue:(r,c)=>r[c],allowEdit:()=>true,
    setValue(r,c,v){const old=r[c];r[c]=v;subs.forEach(s=>s.onChange("set",{record:r,field:c,oldValue:old}));return "SET";},
    subscribe(s){subs.push(s);return "s";},unSubscribe(){},
    revertRecords(recs){recs.forEach(r=>{r.P=r.ID==="1"?"2":"";});subs.forEach(s=>s.onChange("revert",{records:recs}));}};
   const view={model,view$:{0:grid,grid(m){if(m==="getColumns")return [];if(m==="inEditMode")return false;if(m==="getActiveRecord")return active;}}};
   let impl=null;
   window.apex={jQuery:()=>({off(){return this;},on(){return this;}}),item:Object.assign(()=>({}),{create(id,i){impl=i;}}),
    region:()=>({call(m){return m==="getViews"?view:{lookup:()=>null};}}),event:{trigger(){}},message:{alert(){}},util:{escapeHTML:s=>String(s)},
    server:{async plugin(id,data){requests.push({op:data.x01,token:data.x02||"",key:data.x03});
     return data.x01==="OPEN"?{ok:true,token:own,files:[]}:{ok:true,files:[{id:"N",name:"n.txt",mime:"text/plain",size:1,ready:true,staged:true}]};}}};
   const col=igaAttachments.init({item:"COL_P",region:"RGRID6",ajax:"P",accept:".txt",maxBytes:1000,maxCount:3,
    fields:[{n:1,kind:"TEXT",label:"Remark",max:30}]});
   // open row 1 and close without a change, open again: the second OPEN presents the first token
   // (the dialog's close event - and so the panel's onclose - comes in a later task)
   const tick=()=>new Promise(r=>setTimeout(r,50));
   await col.open(rows["1"]);document.getElementById("COL_P_PANEL").close();await tick();
   await col.open(rows["1"]);document.getElementById("COL_P_PANEL").close();await tick();
   const opens=requests.filter(r=>r.op==="OPEN").map(r=>r.token);
   // a pasted foreign token is taken off; a pasted count stays
   model.setValue(rows["2"],"P",foreign);const afterPaste=rows["2"].P;
   model.setValue(rows["2"],"P","5");const afterCount=rows["2"].P;
   // the column's own token stays: a file added on row 1, the panel closes, the row holds the token
   await col.open(rows["1"]);
   const fileInput=document.querySelector("#COL_P_PANEL input[type=file]"),dt=new DataTransfer();
   dt.items.add(new File(["x"],"n.txt"));fileInput.files=dt.files;fileInput.onchange();
   await new Promise(r=>setTimeout(r,200));
   const maxLength=document.querySelector("#COL_P_PANEL .iga-field input").maxLength;
   document.getElementById("COL_P_PANEL").close();await tick();
   const ownKept=rows["1"].P;
   // the grid activates row 1's cell (the editor gets the row's token), then the row is saved (the model
   // gets the file count): the editor's token is stale, it reports and shows the row's value
   active=rows["1"];impl.setValue(own);rows["1"].P="1";
   const editorAfterSave=impl.getValue(),editorShows=document.getElementById("COL_P").value;
   impl.setValue("changed");const ownValueKept=impl.getValue();   // not a token: the editor's own value, as set
   // a row with a pending token reverted in the grid: its edit is discarded on the server
   rows["1"].P=own;
   const before=requests.length;model.revertRecords([rows["1"]]);await tick();
   const discard=requests.slice(before);
   col.destroy();grid.remove();delete window.apex;
   return {opens,afterPaste,afterCount,ownKept,maxLength,editorAfterSave,editorShows,ownValueKept,discard};
  });
  assert.equal(r6.maxLength,30,"the field takes the length of the developer's column");
  assert.equal(r6.editorAfterSave,"1","a stale token is not written back: the row's own value is reported");
  assert.equal(r6.editorShows,"1","the editor shows the saved row's value");
  assert.equal(r6.ownValueKept,"changed","setValue / getValue of other values unchanged");
  assert.deepEqual(r6.discard,[{op:"DISCARD",token:"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",key:"1"}],"a reverted row's edit is discarded");
  assert.equal(r6.ownKept,"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","the column's own token stays on its row");
  assert.deepEqual(r6.opens,["","AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"],"the reopen presents the panel's own empty edit");
  assert.equal(r6.afterPaste,"","a pasted token of another row is taken off");
  assert.equal(r6.afterCount,"5","other values are left alone");
  assert.deepEqual(errors,[]);
  console.log("Review regressions passed (Escape saves the field first, field drafts kept and retried, quick fields, fields during an upload, one panel per column, shared save guard).");
 } finally { await browser.close(); }
})().catch(e=>{console.error(e);process.exitCode=1;});
