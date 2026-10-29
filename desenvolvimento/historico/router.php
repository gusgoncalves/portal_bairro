<?php
// Compatibilidade com o comando antigo. Prefira php spark serve.
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if (in_array($path, ['/app.js','/styles.css'],true)) {
 header('Content-Type: '.($path==='/app.js'?'application/javascript':'text/css').'; charset=utf-8');
 readfile(dirname(__DIR__,2).'/public'.$path);return true;
}
require dirname(__DIR__,2).'/public/index.php';
