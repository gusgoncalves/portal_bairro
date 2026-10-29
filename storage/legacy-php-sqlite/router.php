<?php
declare(strict_types=1);
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: same-origin');
if (str_starts_with($path, '/api/')) {
    require __DIR__ . '/backend/api.php';
    return true;
}
$publicFiles = ['/app.js', '/styles.css'];
$image = preg_match('~^/(artes|assets)/[a-zA-Z0-9_/-]+\.(png|jpe?g|webp|svg)$~D', $path) && !str_contains($path, '..');
if (in_array($path, $publicFiles, true) || $image) {
    $file = realpath(__DIR__ . $path);
    if ($file && str_starts_with($file, realpath(__DIR__) . DIRECTORY_SEPARATOR) && is_file($file)) return false;
}
$routes = ['/', '/index.html', '/gestor', '/anunciantes', '/admin', '/servicos', '/anunciar', '/como-funciona'];
if (in_array(rtrim($path, '/') ?: '/', $routes, true) || preg_match('~^/(profissional/\d+|gestor/(anuncios|novo|editar/\d+))/?$~', $path)) {
    header('Content-Type: text/html; charset=utf-8');
    header('Cache-Control: no-store');
    echo str_replace('<head>', '<head><base href="/">', file_get_contents(__DIR__ . '/index.html'));
    return true;
}
http_response_code(404);
echo 'Página não encontrada.';
