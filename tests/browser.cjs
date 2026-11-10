// Browser checks of the standalone demo (demo/index.html). Needs playwright-core (npm install --no-save playwright-core) and Chrome.
const {chromium}=require("playwright-core");
const {pathToFileURL}=require("node:url");
const path=require("node:path"),fs=require("node:fs"),assert=require("node:assert/strict");
(async()=>{
 const out=path.resolve("qa/out");fs.mkdirSync(out,{recursive:true});
 const browser=await chromium.launch(process.env.CHROME?{executablePath:process.env.CHROME,headless:true}:{channel:"chrome",headless:true});
 const page=await browser.newPage({viewport:{width:1366,height:950}});
 const errors=[];page.on("pageerror",e=>errors.push(e.message));
 try {
  await page.goto(pathToFileURL(path.resolve("demo/index.html")).href);
  assert.equal(await page.locator("#rows tr").count(),3);
  await page.screenshot({path:path.join(out,"desktop.png"),fullPage:true});
  await page.locator("#rows tr").first().locator("button").click();
  await page.getByText("hotel-booking.txt",{exact:true}).waitFor();
  await page.locator(".iga-danger").click();
  await page.locator(".iga-done:not(:disabled)").waitFor();
  await page.getByText("Removal pending",{exact:true}).waitFor();
  // the file actions are icon buttons with their label as tooltip
  assert.equal(await page.locator(".iga-icon-button",{hasText:"Restore"}).getAttribute("title"),"Restore");
  await page.locator(".iga-icon-button",{hasText:"Restore"}).click();
  await page.locator(".iga-done:not(:disabled)").waitFor();
  await page.getByText("Saved",{exact:true}).last().waitFor();
  await page.locator('.iga-done:not(:disabled)').waitFor();
  await page.locator('input[type=file]').setInputFiles({
   name:"receipt.txt",mimeType:"text/plain",buffer:Buffer.from("Demo receipt\nSAR 42")
  });
  await page.getByText("receipt.txt",{exact:true}).waitFor();
  await page.getByText("Pending save",{exact:true}).waitFor();
  await page.screenshot({path:path.join(out,"attachments-desktop.png")});
  // Escape closes dialog and focus returns to the triggering cell.
  await page.keyboard.press("Escape");
  assert.equal(await page.locator("dialog").evaluate(d=>d.open),false);
  await page.locator("#save").click();
  assert.match(await page.locator("#notice").innerText(),/Demo saved/);
  await page.locator("#rows tr").first().locator("button").click();
  await page.getByText("receipt.txt",{exact:true}).waitFor();
  const receipt=page.locator(".iga-file").filter({hasText:"receipt.txt"});
  assert.equal(await receipt.locator(".iga-badge").innerText(),"Saved");
  // Existing-file removal must remain pending until save and be undoable by revert.
  await receipt.locator(".iga-danger").click();
  await page.locator(".iga-done:not(:disabled)").waitFor();
  await receipt.getByText("Removal pending",{exact:true}).waitFor();
  await page.getByRole("button",{name:"Done",exact:true}).click();
  await page.locator("#revert").click();
  await page.locator("#rows tr").first().locator("button").click();
  assert.equal(await page.locator(".iga-file").filter({hasText:"receipt.txt"}).locator(".iga-badge").innerText(),"Saved");
  await page.getByRole("button",{name:"Done",exact:true}).click();
  // A new row can receive files before it has a persistent ID.
  await page.locator("#add").click();
  await page.locator("#rows tr").last().locator("button").click();
  await page.locator('.iga-done:not(:disabled)').waitFor();
  await page.locator('input[type=file]').setInputFiles({name:"new.txt",mimeType:"text/plain",buffer:Buffer.from("new row proof")});
  await page.getByText("new.txt",{exact:true}).waitFor();
  await page.getByRole("button",{name:"Done",exact:true}).click();
  await page.locator("#save").click();
  await page.locator("#rows tr").last().locator("button").click();
  assert.equal(await page.locator(".iga-file").filter({hasText:"new.txt"}).locator(".iga-badge").innerText(),"Saved");
  await page.getByRole("button",{name:"Done",exact:true}).click();
  // Check small screens and keyboard-contained native dialog.
  for(const width of [390,768]){
   await page.setViewportSize({width,height:844});
   await page.locator("#rows tr").first().locator("button").click();
   await page.getByText("hotel-booking.txt",{exact:true}).waitFor();
   const overflow=await page.locator("dialog").evaluate(d=>d.scrollWidth>d.clientWidth+1);
   assert.equal(overflow,false);
   await page.screenshot({path:path.join(out,"attachments-"+width+".png")});
   await page.keyboard.press("Escape");
  }
  // Exercise the real APEX adapter against a small model/API double, not just the demo adapter.
  const integration = await page.evaluate(async () => {
   const input=document.createElement('input');input.id='TEST_ATTACH';document.body.append(input);
   const button=document.createElement('button');button.id='TEST_ATTACH_OPEN';document.body.append(button);
   const region=document.createElement('div');region.id='test_ig';document.body.append(region);
   const a={ID:'A',TOKEN:''},b={ID:'B',TOKEN:''};let current=a,locks=0,saves=0,observer,itemImpl;
   const alerts=[],writes=[];const action={action(){saves++;}};
   const model={
    getRecordId:r=>r.ID,getRecordMetadata:()=>({}),getValue:(r,c)=>r[c],allowEdit:()=>true,
    getOption:n=>n==='identityField'?['ID']:n==='fields'?{ID:{},TOKEN:{elementId:'TEST_ATTACH'}}:undefined,
    setValue(r,c,v){r[c]=v;writes.push({id:r.ID,column:c,value:v});return 'SET';},
    subscribe(o){observer=o;return 'sub';},unSubscribe(){}
   };
   const view={model,view$:{grid(method){if(method==='getActiveRecord')return current;
    if(method==='lockActive')locks++;if(method==='unlockActive')locks--;if(method==='inEditMode')return true;if(method==='getColumns')return [];}}};
   const jq=()=>({on(){return this;},off(){return this;}});
   window.apex={jQuery:jq,item:Object.assign(()=>({}),{create(id,impl){itemImpl=impl;}}),
    region:()=>({call(method){if(method==='getViews')return view;if(method==='getActions')return {lookup:()=>action};}}),
    event:{trigger(){}},message:{alert:m=>alerts.push(m)},
    server:{async plugin(id,data){await new Promise(r=>setTimeout(r,15));return {ok:true,token:'ROW_A_TOKEN',files:[]};}}
   };
   const instance=igaAttachments.init({item:'TEST_ATTACH',region:'test_ig',ajax:'test',
    accept:'.txt',maxBytes:100,maxCount:3,readOnly:false});
   const opening=instance.open();current=b;await opening;
   if(locks!==1||writes.length!==0||a.TOKEN!==''||b.TOKEN!=='')throw new Error('Opening the panel changed a row');
   action.action();if(saves!==0||!alerts.length)throw new Error('Save not guarded while panel open');
   const closed=new Promise(resolve=>document.querySelector('#TEST_ATTACH_PANEL').addEventListener('close',resolve,{once:true}));
   document.querySelector('#TEST_ATTACH_PANEL .iga-done').click();await closed;
   if(locks!==0)throw new Error('Active row lock leaked');
   action.action();if(saves!==1)throw new Error('Native save not restored after close');
   const copy={ID:'C',TOKEN:'0123456789ABCDEF0123456789ABCDEF'};observer.onChange('copy',{records:[copy]});
   if(copy.TOKEN!=='')throw new Error('Copy retained original token');
   itemImpl.setValue('changed');if(itemImpl.getValue()!=='changed')throw new Error('Item value lost');
   instance.destroy();action.action();if(saves!==2)throw new Error('Save wrapper leaked after destroy');
   input.remove();button.remove();region.remove();delete window.apex;
   return {capturedRecord:true,activeRowLock:true,saveGuard:true,duplicateCleared:true,itemValue:true,teardown:true};
  });
  assert.equal(integration.teardown,true);
  assert.deepEqual(errors,[]);
  fs.writeFileSync(path.join(out,"browser-results.json"),JSON.stringify({
   status:"passed",checks:["existing-file remove/restore","upload","pending versus saved","new-row linking in mock",
   "revert preserves saved files","Escape closes panel","390/768 px dialog overflow","no browser JS errors"],
   limitation:"Browser UI exercised against an in-memory adapter, not Oracle APEX or PL/SQL."
  },null,2));
  console.log("Browser UI checks passed; screenshots written to qa/.");
 }catch(error){await page.screenshot({path:path.join(out,"failure.png")});console.error(await page.locator(".iga-message").allTextContents());throw error;}finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});

