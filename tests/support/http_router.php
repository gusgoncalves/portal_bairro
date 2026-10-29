<?php
// Somente para QA no executor Windows: mantém a aplicação livre do shim de testes.
require __DIR__.'/sandbox_fs.php';
return require __DIR__.'/../../public/router.php';
