<?php
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$resolved = realpath(__DIR__ . rawurldecode($path));
if ($path !== '/' && $resolved && str_starts_with($resolved, __DIR__ . DIRECTORY_SEPARATOR) && is_file($resolved) && in_array(strtolower(pathinfo($resolved, PATHINFO_EXTENSION)), ['css','js','png','jpg','jpeg','webp','ico'], true)) return false;
require __DIR__ . '/index.php';
