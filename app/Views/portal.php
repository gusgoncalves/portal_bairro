<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><base href="<?= esc(base_url(), 'attr') ?>"><meta name="portal-default" content="<?= esc((string) env('portal.defaultSlug', ''), 'attr') ?>"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#11162a"><meta name="description" content="Empresas e serviços da sua região, em uma vitrine local."><title>Portal do Bairro</title><link rel="stylesheet" href="styles.css"><link rel="stylesheet" href="portal.css"><script src="app.js?v=20261029-3" defer></script><script src="portal.js?v=20261029-3" defer></script><script src="prd.js?v=20261029-3" defer></script><script src="gestao.js?v=20261029-3" defer></script><script src="administracao.js?v=20261029-3" defer></script><link rel="stylesheet" href="prd.css"><link rel="stylesheet" href="gestao.css?v=20261029-3"></head><body>
<svg class="icon-library" aria-hidden="true"><defs>
<symbol id="v-building" viewBox="0 0 24 24"><path d="M7 21V3h10v18M3 21V9h4m10 2h4v10M2 21h20M10 7h4m-4 4h4m-4 4h4m-4 6v-3h4v3"/></symbol>
<symbol id="v-search" viewBox="0 0 24 24"><circle cx="10.5" cy="10.5" r="7.5"/><path d="m16 16 5 5"/></symbol>
<symbol id="v-pin" viewBox="0 0 24 24"><path d="M20 10c0 6-8 11-8 11S4 16 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/></symbol>
<symbol id="v-arrow" viewBox="0 0 24 24"><path d="M5 12h14m-6-6 6 6-6 6"/></symbol>
<symbol id="v-close" viewBox="0 0 24 24"><path d="m6 6 12 12M18 6 6 18"/></symbol>
<symbol id="v-chat" viewBox="0 0 24 24"><path d="M21 11.5a9 9 0 0 1-13 8L3 21l1.5-5A9 9 0 1 1 21 11.5Z"/></symbol>
<symbol id="v-clock" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></symbol>
<symbol id="v-instagram" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><path d="M17 7h.01"/></symbol>
<symbol id="v-grid" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></symbol>
<symbol id="v-tool" viewBox="0 0 24 24"><path d="M14 6a5 5 0 0 0-6 6l-5 5a2 2 0 0 0 3 3l5-5a5 5 0 0 0 7-6l-4 4-3-3 4-4Z"/></symbol>
<symbol id="v-scissors" viewBox="0 0 24 24"><circle cx="5" cy="6" r="3"/><circle cx="5" cy="18" r="3"/><path d="m8 8 12 12M8 16 20 4"/></symbol>
<symbol id="v-zap" viewBox="0 0 24 24"><path d="m13 2-9 12h7l-1 8 10-13h-7z"/></symbol>
<symbol id="v-spark" viewBox="0 0 24 24"><path d="m12 3 3 6 6 3-6 3-3 6-3-6-6-3 6-3z"/></symbol>
<symbol id="v-food" viewBox="0 0 24 24"><path d="M4 3v6a3 3 0 0 0 6 0V3M7 3v18M19 21V3c-4 1-5 9 0 10"/></symbol>
</defs></svg>
<header class="site-header"><div class="shell header-row"><a class="portal-brand" href="#/" aria-label="Portal do Bairro, início"><span class="brand-symbol"><svg class="v-icon"><use href="#v-building"/></svg></span><span><strong>Portal do Bairro<span>.</span></strong><small>Gente perto. Boas conexões.</small></span></a><div class="region-control" hidden><svg class="v-icon"><use href="#v-pin"/></svg><label for="portal-region"><span>SUA REGIÃO</span><select id="portal-region" aria-label="Região atual"><option>Carregando região…</option></select></label></div></div></header>
<main id="app" tabindex="-1"><div class="container panel" role="status">Carregando o portal…</div></main>
<footer class="shell portal-footer"><a href="#/">Portal do Bairro<span>.</span></a><p>Divulgação de empresas e serviços locais.<br>A contratação é combinada diretamente com a empresa.</p><a href="#/como-funciona">Sobre a iniciativa ↗</a></footer>
<dialog id="notice"><div class="dialog-head"><h2 id="notice-title">Informação</h2><button id="close-notice" class="icon-button" aria-label="Fechar">×</button></div><p id="notice-message"></p><button id="notice-ok" class="button">Entendi</button></dialog>
<dialog id="company-dialog" class="company-dialog" aria-labelledby="company-title"></dialog>
<dialog id="photo-dialog" class="photo-dialog" aria-labelledby="photo-caption"></dialog>
</body></html>
