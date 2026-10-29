/* Tema aprovado e fluxo de revisão conectado à API CodeIgniter. */
'use strict';
let reviewData=null;
let editorPublished=null;
let availablePortals=[];
const publicFilter={query:'',category:'all'};
const vIcon=name=>`<svg class="v-icon" aria-hidden="true"><use href="#v-${name}"/></svg>`;
const categoryIcons={reformas:'tool',beleza:'scissors',limpeza:'spark',alimentacao:'food',jardim:'spark',eletrica:'zap'};
const orderedImages=b=>[...(b.images||[])].sort((a,b)=>Number(a.slot)-Number(b.slot));
const companyPicture=b=>orderedImages(b)[0]?.url||(b.images===undefined?b.art:'')||'assets/empresa-padrao.svg';

function syncPortalHeader(){
 const select=document.getElementById('portal-region');if(!select)return;
 const list=availablePortals.length?availablePortals:[{slug:portalSlug,name:portal.name}];
 select.innerHTML=list.map(p=>`<option value="${esc(p.slug)}" ${p.slug===portalSlug?'selected':''}>${esc(p.name)}</option>`).join('');
}
home=function(){return `<section class="search-band"><div class="shell search-row"><div class="search-intro"><small>DESCUBRA EMPRESAS E SERVIÇOS</small><h1>Encontre quem pode <em>ajudar.</em></h1></div><form class="live-search" id="catalog-search" role="search">${vIcon('search')}<label class="sr-only" for="live-search">Pesquisar empresa ou serviço</label><input id="live-search" type="search" value="${esc(publicFilter.query)}" placeholder="Busque por manicure, pedreiro, bolo…" autocomplete="off"><button>Encontrar ${vIcon('arrow')}</button></form></div></section><section class="shell catalogue"><div class="catalogue-top"><div><span class="catalogue-label">CATEGORIAS POPULARES</span><h2>Conheça as empresas desta vitrine.</h2></div><span id="result-count" class="result-count" role="status" aria-live="polite"></span></div><div id="public-categories" class="portal-categories" aria-label="Categorias de serviços"></div><div id="catalog-grid" class="catalog-cards"></div><div id="catalog-empty" class="empty-catalog" hidden><h2>Nenhuma empresa encontrada.</h2><p>Tente outro termo ou remova os filtros de categoria.</p><button class="button" id="clear-catalog">Limpar filtros</button></div></section>`;};
card=function(b){return `<article class="business-card"><button class="business-cover" data-company="${b.id}" aria-label="Conhecer ${esc(b.name)}"><img src="${esc(companyPicture(b))}" alt="${esc(b.art?'Imagem de '+b.name:'Imagem padrão da empresa')}" loading="lazy"><span class="cover-tags"><span>${esc(cat(b.category)?.name||b.category)}</span>${!b.images?.length?'<span class="picture-note">Imagem não cadastrada</span>':''}</span><span class="business-title"><strong>${esc(b.name)}</strong><small>${esc(b.service)}</small></span></button><div class="business-body"><div class="business-meta"><span>Conheça este negócio</span><small>${esc(b.mode)}</small></div><p class="business-description">${esc(b.description)}</p><p class="business-address">${vIcon('pin')} ${esc(b.address||b.area||portal.name)}</p><div class="business-actions">${b.instagram?`<a class="instagram-button" href="https://www.instagram.com/${esc(b.instagram)}/" target="_blank" rel="noopener noreferrer" aria-label="Instagram de ${esc(b.name)}">${vIcon('instagram')} Instagram</a>`:`<button disabled title="Instagram não informado pela empresa">${vIcon('instagram')} Instagram</button>`}${b.whatsapp?`<a class="contact-button" href="https://wa.me/${esc(b.whatsapp)}" target="_blank" rel="noopener noreferrer">${vIcon('chat')} WhatsApp</a>`:`<button disabled title="WhatsApp não informado pela empresa">${vIcon('chat')} WhatsApp</button>`}</div></div></article>`;};
function drawCatalogue(){
 const grid=document.getElementById('catalog-grid');if(!grid)return;
 const list=published().filter(b=>(publicFilter.category==='all'||b.category===publicFilter.category)&&normalized([b.name,b.service,b.description,b.tags,...b.services].join(' ')).includes(normalized(publicFilter.query.trim())));
 grid.innerHTML=list.map(card).join('');grid.hidden=!list.length;
 document.getElementById('result-count').textContent=`${list.length} ${list.length===1?'empresa encontrada':'empresas encontradas'}`;
 document.getElementById('catalog-empty').hidden=!!list.length;
 document.getElementById('public-categories').innerHTML=[{id:'all',name:'Todos'},...categories].map(c=>`<button class="${c.id===publicFilter.category?'active':''}" data-public-category="${c.id}" aria-pressed="${c.id===publicFilter.category}">${vIcon(categoryIcons[c.id]||'grid')}${esc(c.name)}</button>`).join('');
 document.querySelectorAll('[data-public-category]').forEach(button=>button.onclick=()=>{publicFilter.category=button.dataset.publicCategory;drawCatalogue();});
 document.querySelectorAll('[data-company]').forEach(button=>button.onclick=()=>openCompany(businesses.find(b=>b.id===Number(button.dataset.company))));
}
function openCompany(b,options={}){
 if(!b)return;const dialog=document.getElementById('company-dialog'),images=orderedImages(b),picture=companyPicture(b);
 const preview=options.preview?`<p class="company-preview-note" role="status">${options.unsaved?'Prévia local: alterações ainda não enviadas.':b.has_pending?'Prévia da proposta: depende de aprovação para aparecer na vitrine.':'Visualização do anúncio, no mesmo formato da vitrine.'}</p>`:'';
 dialog.innerHTML=`<div class="company-cover"><button class="company-cover-open" data-open-photo="${esc(picture)}" data-photo-caption="${esc(b.name)}" aria-label="Ampliar a imagem principal"><img id="company-main-image" src="${esc(picture)}" alt="${esc(b.name)}"></button><button class="company-close" aria-label="Fechar anúncio">${vIcon('close')}</button><div class="company-cover-title"><small>${esc(cat(b.category)?.name||b.category)}</small><h2 id="company-title">${esc(b.name)}</h2></div></div><div class="company-detail">${preview}<div class="company-summary"><div><span>ATENDIMENTO</span><b>${esc(b.mode)}</b></div><div><span>LOCALIZAÇÃO</span><b>${esc(portal.name)}</b></div><div><span>CONTRATAÇÃO</span><b>Contato direto</b></div></div><h3>SOBRE A EMPRESA</h3><p class="preserve-lines">${esc(b.description)}</p><div class="service-list">${b.services.map(s=>`<span class="badge">${esc(s)}</span>`).join(' ')}</div><div class="company-info"><p><b>Atendimento:</b> ${esc(b.hours)}</p><p><b>Endereço / região:</b> ${esc(b.address||b.area||portal.name)}</p>${b.instagram?`<p><b>Instagram:</b> <a href="https://www.instagram.com/${esc(b.instagram)}/" target="_blank" rel="noopener noreferrer">${vIcon('instagram')} @${esc(b.instagram)}</a></p>`:''}</div>${images.length>1?`<h3>MAIS FOTOS DA EMPRESA</h3><div class="company-gallery extra-photos">${images.slice(1,3).map(i=>`<button data-open-photo="${esc(i.url)}" data-photo-caption="${esc(i.caption)}" aria-label="Ampliar ${esc(i.caption)}"><img src="${esc(i.url)}" alt="${esc(i.caption)}"><span>Ampliar</span></button>`).join('')}</div>`:!images.length?'<p>Esta empresa ainda não adicionou fotos.</p>':''}${b.whatsapp?`<a class="contact-button" href="https://wa.me/${esc(b.whatsapp)}" target="_blank" rel="noopener noreferrer">${vIcon('chat')} Conversar pelo WhatsApp</a>`:'<p>Contato ainda não informado pela empresa.</p>'}<p class="company-disclaimer">Divulgação de empresas e serviços. A contratação acontece diretamente com a empresa.</p></div>`;
 dialog.querySelector('.company-close').onclick=()=>dialog.close();
 bindPhotoButtons(dialog);dialog.showModal();dialog.scrollTop=0;document.body.style.overflow='hidden';
}
function openPhoto(url,caption='Foto da empresa'){
 const dialog=document.getElementById('photo-dialog');if(!dialog)return;
 dialog.innerHTML=`<button class="photo-close" aria-label="Fechar foto ampliada">${vIcon('close')}</button><figure><img src="${esc(url)}" alt="${esc(caption)}"><figcaption id="photo-caption">${esc(caption)}</figcaption></figure>`;
 dialog.querySelector('.photo-close').onclick=()=>dialog.close();dialog.showModal();document.body.style.overflow='hidden';
}
function bindPhotoButtons(scope=document){scope.querySelectorAll('[data-open-photo]').forEach(button=>button.onclick=()=>openPhoto(button.dataset.openPhoto,button.dataset.photoCaption));}
const companyDialog=document.getElementById('company-dialog');
companyDialog?.addEventListener('close',()=>document.body.style.overflow='');
companyDialog?.addEventListener('click',event=>{if(event.target===companyDialog){const r=companyDialog.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)companyDialog.close();}});
const publicationStatus=status;
status=function(b){return publicationStatus(b)+(b.revision?.status==='pending'?'<br><span class="review-badge">Alterações aguardando aprovação</span>':b.revision?.status==='rejected'?'<br><span class="review-badge rejected">Devolvido para ajuste</span>':'');};
table=function(list){return `<div class="table-wrap"><table><caption class="sr-only">Empresas e situação das propostas</caption><thead><tr><th>Empresa</th><th>Imagens</th><th>Situação</th><th>Ações</th></tr></thead><tbody>${list.map(b=>`<tr><td><strong>${esc(b.name)}</strong><br><small>${esc(b.service)}</small><div class="responsible-inline"><strong>Responsável pelo acesso</strong>${responsibleView(b.responsaveis)}</div></td><td><div class="catalog-image-list">${b.images?.length?orderedImages(b).map((i,index)=>`<button data-open-photo="${esc(i.url)}" data-photo-caption="${esc(i.caption)}" aria-label="Ampliar ${esc(i.caption)}"><img src="${esc(i.url)}" alt="${esc(i.caption)}"><span>${index===0?'Capa':'Foto '+(index+1)}</span></button>`).join(''):`<button data-preview="${b.id}" aria-label="Ver capa ilustrativa"><img src="${esc(companyPicture(b))}" alt="Capa ilustrativa"><span>Ilustrativa</span></button>`}</div></td><td>${status(b)}</td><td><div class="table-actions"><button data-preview="${b.id}">Visualizar anúncio</button><a href="#/gestor/editar/${b.id}">Editar / imagens</a>${b.has_pending?`<a href="#/gestor/revisar/${b.id}">Revisar proposta</a>`:b.status!=='pending'?`<button data-toggle="${b.id}">${b.status==='published'?'Suspender':'Reativar aprovado'}</button>`:''}<button data-access="${b.id}">Criar acesso da empresa</button><button data-archive="${b.id}">Arquivar</button></div></td></tr>`).join('')}</tbody></table></div>`;};
advertiserPanel=function(){return `${heading('Meu catálogo','Edite seu anúncio e confira a prévia antes da aprovação.')}<section class="container">${ownerNav()}<div class="panel"><h2>Meu Anúncio</h2>${businesses.map(b=>`<div class="owner-business"><button class="owner-cover-button" data-preview="${b.id}" aria-label="Visualizar ${esc(b.name)}"><img src="${esc(companyPicture(b))}" alt="${esc(b.name)}"></button><h3>${esc(b.name)}</h3><p>${esc(b.service)}</p>${status(b)}${b.revision?.status==='rejected'?`<p class="micro">Motivo da devolução: ${esc(b.revision.note)}</p>`:''}<div class="form-actions"><a class="button small" href="#/anunciantes/editar/${b.id}">Editar anúncio e imagens</a><button class="button secondary small" data-preview="${b.id}">Visualizar anúncio</button></div></div>`).join('')||'<p>Nenhuma empresa vinculada à sua conta.</p>'}</div></section>`;};
profile=function(id){return businesses.some(b=>b.id===Number(id)&&b.status==='published')?home():notFound();};
function reviewQueue(){const pending=businesses.filter(b=>b.has_pending);return `${heading('Propostas para aprovação','Analise o conteúdo e as imagens antes de publicar.')}<section class="container">${dashboardNav('reviews')}<div class="panel"><h2>${pending.length} propostas aguardando análise</h2>${pending.length?table(pending):'<p>Nenhuma proposta pendente.</p>'}</div></section>`;}
function reviewSnapshot(b,label,isLive){
 const names={name:'Nome da empresa',service:'Serviço principal',category:'Categoria',description:'Apresentação',mode:'Modalidade',hours:'Horário',address:'Endereço',area:'Área atendida',whatsapp:'WhatsApp',instagram:'Instagram',tags:'Palavras-chave',services:'Serviços oferecidos'};
 return `<div class="panel"><h2>${label}</h2>${!isLive?'<p class="micro">Esta empresa ainda não possui um card publicado.</p>':''}<dl class="review-fields">${Object.entries(names).map(([key,name])=>`<dt>${name}</dt><dd>${esc(key==='category'?(cat(b[key])?.name||b[key]):Array.isArray(b[key])?b[key].join('\n'):b[key]||'Não informado')}</dd>`).join('')}</dl><h3>Imagens (${b.images?.length||0}/3)</h3><div class="review-images">${(b.images||[]).map(i=>`<img src="${esc(i.url)}" alt="${esc(i.caption)}">`).join('')||'<p>Nenhuma imagem nesta versão.</p>'}</div></div>`;
}
function reviewPage(){if(!reviewData)return '<section class="container panel">Carregando revisão…</section>';const {approved,proposed}=reviewData;const r=proposed.revision;return `${heading('Revisão de '+proposed.name,'Compare a versão aprovada com a proposta enviada.')}<section class="container">${dashboardNav('reviews')}${!r?'<div class="panel">Não há proposta para analisar.</div>':`<div class="callout">Enviado por ${esc(r.author)} · versão ${r.version}${r.status==='rejected'?' · Devolvido: '+esc(r.note):r.status==='approved'?' · Já aprovado':''}</div><div class="review-columns">${reviewSnapshot(approved,'Versão pública atual',approved.status==='published')}${reviewSnapshot(proposed,'Proposta enviada',true)}</div>${r.status==='pending'?`<div class="review-toolbar"><label for="review-note">Observação / motivo da devolução</label><textarea id="review-note" class="review-note" maxlength="1000" placeholder="Informe o que precisa ser ajustado, se devolver a proposta."></textarea><div class="form-actions"><button class="button" data-review-decision="approve">Aprovar e publicar esta versão</button><button class="button secondary" data-review-decision="reject">Devolver para ajuste</button><button class="button secondary" id="reload-review">Atualizar comparação</button></div><p id="review-error" role="alert" class="form-message"></p></div>`:''}`}</section>`;}
const editBeforeReview=edit;
edit=function(id){let html=editBeforeReview(id);const b=businesses.find(x=>x.id===Number(id)),data=b||{name:'Sua empresa',category:'reformas',images:[]};
 if(b?.revision?.status==='rejected')html=html.replace('<form id="edit-form"',`<div class="callout">Proposta devolvida: ${esc(b.revision.note)}. Corrija e envie novamente para análise.</div><form id="edit-form"`);
 const published=editorPublished?.published&&Number(editorPublished.publication?.id)===Number(id)?editorPublished.publication:null;
 const cover=`<div class="editor-cover-section"><div><h3>Capa da versão em edição</h3><button type="button" id="editor-cover-open" data-open-photo="${esc(companyPicture(data))}" data-photo-caption="Capa da versão em edição"><img id="editor-cover-image" src="${esc(companyPicture(data))}" alt="Capa da versão em edição"></button><p class="micro">Esta é a capa que aparecerá na prévia e será enviada para aprovação.</p></div>${published?`<div class="approved-cover"><h3>Versão pública atual</h3><img src="${esc(companyPicture(published))}" alt="Capa atualmente aprovada"><p class="micro">Continua no ar enquanto a nova proposta aguarda aprovação.</p></div>`:''}</div>`;
 html=html.replace('<div class="form-grid">',cover+'<div class="form-grid">');
 html=html.replace('<button class="button" type="submit">Enviar para aprovação</button>','<button class="button" type="submit">Enviar para aprovação</button><button type="button" class="button secondary" id="preview-editor">Visualizar anúncio</button>');
 return html;
};
const bindBeforeApproval=bind;
bind=function(){
 bindBeforeApproval();
 drawCatalogue();
 document.getElementById('live-search')?.addEventListener('input',event=>{publicFilter.query=event.target.value;drawCatalogue();});
 document.getElementById('catalog-search')?.addEventListener('submit',event=>{event.preventDefault();publicFilter.query=document.getElementById('live-search').value;drawCatalogue();});
 document.getElementById('clear-catalog')?.addEventListener('click',()=>{publicFilter.query='';publicFilter.category='all';document.getElementById('live-search').value='';drawCatalogue();});
 document.getElementById('reload-review')?.addEventListener('click',async()=>{try{await refresh();}catch(error){showNotice('Não foi possível atualizar',error.message);}});
 document.querySelectorAll('[data-review-decision]').forEach(button=>button.onclick=async()=>{
  const r=reviewData.proposed.revision;const note=document.getElementById('review-note').value;
  const buttons=[...document.querySelectorAll('[data-review-decision]')];buttons.forEach(b=>b.disabled=true);
  try{await api('/publications/'+reviewData.proposed.id+'/review',{method:'POST',body:JSON.stringify({decision:button.dataset.reviewDecision,revision_id:r.id,version:r.version,note})});location.hash='/gestor/revisoes';}
  catch(error){document.getElementById('review-error').textContent=error.message;buttons.forEach(b=>b.disabled=false);}
 });
};
document.getElementById('portal-region')?.addEventListener('change',async event=>{portalSlug=event.target.value;publicFilter.query='';publicFilter.category='all';const url=new URL(location.href);url.searchParams.set('portal',portalSlug);history.replaceState(null,'',url);if(currentPath()==='/')await refresh();else location.hash='/';});
const bootWithApproval=boot;
boot=async function(){try{availablePortals=(await api('/portals')).portals;}catch{}await bootWithApproval();};
// Inicialização ao final do módulo.

let savedEditorState=null;
let pendingPhotoUrls=[];
function catalogueErrors(values,files=[],existing=0){
 const errors={},labels={name:'nome da empresa',service:'serviço principal',description:'apresentação',hours:'horário'};
 for(const key of Object.keys(labels))if(!String(values[key]||'').trim())errors[key]='Preencha '+labels[key]+'.';
 for(const [key,max] of Object.entries({name:120,service:100,description:1500,tags:200,hours:120,address:200,area:200,whatsapp:30,instagram:200}))if(String(values[key]||'').length>max)errors[key]='Use até '+max+' caracteres.';
 const phone=String(values.whatsapp||'').replace(/[\s()+.-]/g,'');
 if(phone&&!/^[1-9][0-9]{9,14}$/.test(phone))errors.whatsapp='Informe código do país, DDD e número. Exemplo: 5542999999999.';
 let instagram=String(values.instagram||'').trim().replace(/^https:\/\/(?:www\.)?instagram\.com\/([A-Za-z0-9._]{1,30})\/?(?:\?.*)?$/,'$1').replace(/^@/,'');
 if(instagram&&!/^[A-Za-z0-9._]{1,30}$/.test(instagram))errors.instagram='Use @usuario ou o link https://www.instagram.com/usuario/.';
 const services=String(values.services||'').split('\n').map(s=>s.trim()).filter(Boolean);
 if(!services.length||services.length>20)errors.services='Informe de 1 a 20 serviços, um por linha.';
 else if(services.some(s=>s.length>150))errors.services='Cada serviço deve ter até 150 caracteres.';
 if(files.length+existing>3)errors.images='São permitidas no máximo 3 imagens. Remova uma para adicionar outra.';
 else if(files.some(f=>f.size>5*1024*1024||!['image/jpeg','image/png','image/webp'].includes(f.type)))errors.images='Use JPG, PNG ou WebP de até 5 MB por imagem.';
 return errors;
}
function errorControl(form,key){return key==='images'?form.querySelector('#company-images'):form.elements.namedItem(key);}
function ensureFieldBox(form,key){
 const control=errorControl(form,key);if(!control||typeof control.setAttribute!=='function')return null;
 const id=(form.id||'formulario')+'-error-'+key;let box=document.getElementById(id);
 if(!box){box=document.createElement('span');box.id=id;box.className='field-error';box.setAttribute('role','alert');control.insertAdjacentElement('afterend',box);}
 const described=(control.getAttribute('aria-describedby')||'').split(' ').filter(Boolean);if(!described.includes(id))described.push(id);
 control.setAttribute('aria-describedby',described.join(' '));return {control,box};
}
function setFieldError(form,key,message){
 const item=ensureFieldBox(form,key);if(!item)return;
 item.box.textContent=message||'';item.box.hidden=!message;item.control.setAttribute('aria-invalid',message?'true':'false');
 if(typeof item.control.setCustomValidity==='function')item.control.setCustomValidity(message||'');
}
function showFieldErrors(form,errors){
 if(!form)return;let first=null;
 for(const [key,message] of Object.entries(errors)){if(!/^[a-z_]+$/.test(key))continue;setFieldError(form,key,message);first??=errorControl(form,key);}
 const summary=form.querySelector('#form-message');if(summary)summary.textContent='';
 first?.focus();first?.scrollIntoView?.({behavior:'smooth',block:'center'});
}
function validateCatalogueForm(form){
 const values=Object.fromEntries(new FormData(form)),input=form.querySelector('#company-images');
 const errors=catalogueErrors(values,[...(input?.files||[])],Number(input?.dataset.existing||0));
 for(const control of form.querySelectorAll('[name]'))setFieldError(form,control.name,'');setFieldError(form,'images','');
 if(Object.keys(errors).length){showFieldErrors(form,errors);return false;}return true;
}
function captureEditor(form){return {id:form.dataset.id,portal:portalSlug,values:Object.fromEntries(new FormData(form)),files:[...(form.querySelector('#company-images')?.files||[])]};}
function editorDraft(form){
 const existing=businesses.find(b=>b.id===Number(form.dataset.id))||{};
 const values=Object.fromEntries(new FormData(form)),files=[...(form.querySelector('#company-images')?.files||[])];
 pendingPhotoUrls.forEach(url=>URL.revokeObjectURL(url));pendingPhotoUrls=[];
 const images=orderedImages(existing),used=images.map(i=>Number(i.slot)),free=[1,2,3].filter(n=>!used.includes(n));
 files.slice(0,free.length).forEach((file,index)=>{const url=URL.createObjectURL(file);pendingPhotoUrls.push(url);images.push({id:'local-'+index,url,slot:free[index],caption:file.name,source:'local'});});
 images.sort((a,b)=>Number(a.slot)-Number(b.slot));
 let instagram=String(values.instagram||'').trim().replace(/^https:\/\/(?:www\.)?instagram\.com\/([A-Za-z0-9._]{1,30})\/?(?:\?.*)?$/,'$1').replace(/^@/,'');if(!/^[A-Za-z0-9._]{1,30}$/.test(instagram))instagram='';
 const phone=String(values.whatsapp||'').replace(/[\s()+.-]/g,'');
 return {...existing,...values,name:values.name||'Sua empresa',services:String(values.services||'').split('\n').map(s=>s.trim()).filter(Boolean),images,art:images[0]?.url||'',instagram,whatsapp:/^[1-9][0-9]{9,14}$/.test(phone)?phone:'',has_pending:true};
}
function updateEditorCover(form){
 const cover=document.getElementById('editor-cover-image');if(!cover)return;
 const draft=editorDraft(form),url=companyPicture(draft);cover.src=url;
 const button=document.getElementById('editor-cover-open');if(button)button.dataset.openPhoto=url;
}
function bindEditorFields(form){
 form.noValidate=true;
 for(const control of form.querySelectorAll('input[name],select[name],textarea[name]')){
  ensureFieldBox(form,control.name);
  control.addEventListener('input',()=>{setFieldError(form,control.name,'');if(['name','category'].includes(control.name))updateEditorCover(form);});
  control.addEventListener('blur',()=>{const errors=catalogueErrors(Object.fromEntries(new FormData(form)));setFieldError(form,control.name,errors[control.name]||'');});
 }
 ensureFieldBox(form,'images');
 const input=form.querySelector('#company-images');
 input?.addEventListener('change',()=>{
  const errors=catalogueErrors(Object.fromEntries(new FormData(form)),[...input.files],Number(input.dataset.existing||0));
  setFieldError(form,'images',errors.images||'');const summary=document.getElementById('form-message');if(summary)summary.textContent='';
  updateEditorCover(form);
 });
 document.getElementById('preview-editor')?.addEventListener('click',()=>openCompany(editorDraft(form),{preview:true,unsaved:true}));
}
const bindBeforeCatalogueAdjustments=bind;
bind=function(){
 bindBeforeCatalogueAdjustments();
 pendingPhotoUrls.forEach(url=>URL.revokeObjectURL(url));pendingPhotoUrls=[];
 const form=document.getElementById('edit-form');let restoredFiles=false;
 if(form){
  if(savedEditorState&&savedEditorState.id===form.dataset.id&&savedEditorState.portal===portalSlug){
   for(const [key,value] of Object.entries(savedEditorState.values)){const control=form.elements.namedItem(key);if(control&&typeof value==='string')control.value=value;}
   const input=form.querySelector('#company-images');
   if(input&&savedEditorState.files.length&&typeof DataTransfer!=='undefined'){const transfer=new DataTransfer();savedEditorState.files.forEach(file=>transfer.items.add(file));input.files=transfer.files;restoredFiles=true;}
  }
  savedEditorState=null;
  if(typeof form.querySelectorAll==='function'&&form.elements){bindEditorFields(form);updateEditorCover(form);if(restoredFiles)form.querySelector('#company-images').dispatchEvent(new Event('change',{bubbles:true}));}
 }
 bindPhotoButtons();
 document.querySelectorAll('[data-preview]').forEach(button=>button.onclick=()=>openCompany(businesses.find(b=>b.id===Number(button.dataset.preview)),{preview:true}));
 document.querySelectorAll('[data-delete-image]').forEach(button=>button.onclick=()=>{
  const state=form?captureEditor(form):null;
  openAction('Remover imagem da proposta','<p class="wide">Você poderá enviar outra imagem. A remoção só aparecerá na vitrine depois da aprovação.</p>',async()=>{
   await api('/publications/'+button.dataset.publication+'/images/'+button.dataset.deleteImage+'?source='+button.dataset.source,{method:'DELETE'});savedEditorState=state;
  });
 });
 document.querySelectorAll('[data-set-cover]').forEach(button=>button.onclick=async()=>{
  button.disabled=true;const state=form?captureEditor(form):null;
  try{await api('/publications/'+button.dataset.publication+'/images/'+button.dataset.setCover+'/cover?source='+button.dataset.source,{method:'POST',body:'{}'});savedEditorState=state;await refresh();}
  catch(error){button.disabled=false;showNotice('Não foi possível definir a capa',error.message);}
 });
 const match=currentPath().match(/^\/profissional\/(\d+)$/);if(match){const business=businesses.find(b=>b.id===Number(match[1]));if(business)openCompany(business);}
};
const photoDialog=document.getElementById('photo-dialog');
photoDialog?.addEventListener('close',()=>document.body.style.overflow=document.getElementById('company-dialog')?.open?'hidden':'');
photoDialog?.addEventListener('click',event=>{if(event.target===photoDialog){const r=photoDialog.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)photoDialog.close();}});
// Inicialização após os módulos PRD.
