<?php
declare(strict_types=1);

function db(): PDO
{
    static $connection;
    if (!$connection) {
        $path = getenv('PORTAL_DB_PATH') ?: dirname(__DIR__) . '/storage/portal.sqlite';
        if (!is_file($path)) {
            throw new RuntimeException('Banco ausente. Execute php bin/setup.php.');
        }
        $connection = new PDO('sqlite:' . $path, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
        $connection->exec('PRAGMA foreign_keys=ON; PRAGMA busy_timeout=5000;');
    }
    return $connection;
}

function query(string $sql, array $params = []): PDOStatement
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt;
}

function respond(array $data, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
    exit;
}

function fail(string $message, int $status): never
{
    respond(['error' => $message], $status);
}

function body(): array
{
    if ((int) ($_SERVER['CONTENT_LENGTH'] ?? 0) > 20000) fail('Requisição muito grande.', 413);
    $input = file_get_contents('php://input', false, null, 0, 20001);
    if (strlen($input) > 20000) fail('Requisição muito grande.', 413);
    try { $data = json_decode($input, true, 32, JSON_THROW_ON_ERROR); }
    catch (JsonException) { fail('JSON inválido.', 400); }
    if (!is_array($data) || array_is_list($data)) fail('Dados inválidos.', 400);
    return $data;
}

function currentUser(): ?array
{
    if (isset($_SESSION['last_seen']) && time() - $_SESSION['last_seen'] > 3600) {
        $_SESSION = [];
        session_regenerate_id(true);
    }
    $_SESSION['last_seen'] = time();
    if (!isset($_SESSION['user_id'])) return null;
    return query('SELECT id,name,email,role,advertiser_id FROM users WHERE id=?', [$_SESSION['user_id']])->fetch() ?: null;
}

function csrf(): void
{
    if (!hash_equals($_SESSION['csrf'], $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '')) fail('Sessão inválida. Recarregue a página.', 419);
}

function authorize(?array $user, int $portalId, bool $manager = false): void
{
    if (!$user) fail('Entre na sua conta.', 401);
    if ($user['role'] === 'master') return;
    if ($manager && $user['role'] !== 'manager') fail('Acesso não permitido.', 403);
    if (!query('SELECT 1 FROM memberships WHERE user_id=? AND portal_id=?', [$user['id'], $portalId])->fetchColumn()) fail('Portal não autorizado.', 403);
}

function publicPublication(array $row): array
{
    $keys = ['id','name','category','service','description','tags','color','accent','type','mode','hours','art','status'];
    $out = array_intersect_key($row, array_flip($keys));
    $out['id'] = (int) $out['id'];
    $out['services'] = json_decode($row['services'], true, 32, JSON_THROW_ON_ERROR);
    return $out;
}

function validatePublication(array $data): array
{
    $limits = ['name'=>70,'service'=>70,'description'=>300,'hours'=>100,'tags'=>150,'art'=>300];
    $out = [];
    foreach ($limits as $key=>$limit) {
        if (isset($data[$key]) && !is_string($data[$key])) fail('Campo inválido: ' . $key, 422);
        $out[$key] = trim($data[$key] ?? '');
        if (mb_strlen($out[$key]) > $limit) fail('Campo muito longo: ' . $key, 422);
        if (in_array($key, ['name','service','description','hours'], true) && $out[$key] === '') fail('Preencha os campos obrigatórios.', 422);
    }
    if ($out['art'] !== '' && (!preg_match('~^(artes|assets)/[a-zA-Z0-9_/-]+\.(png|jpe?g|webp|svg)$~D', $out['art']) || str_contains($out['art'], '..'))) fail('Caminho de arte inválido.', 422);
    if (!is_string($data['category'] ?? null) || !in_array($data['category'], ['reformas','beleza','limpeza','alimentacao','jardim'], true)) fail('Categoria inválida.', 422);
    if (!is_string($data['mode'] ?? null) || !in_array($data['mode'], ['A domicílio','Em estabelecimento','Encomendas e retirada'], true)) fail('Atendimento inválido.', 422);
    $services = $data['services'] ?? [];
    if (!is_array($services) || !array_is_list($services) || count($services) < 1 || count($services) > 20) fail('Informe de 1 a 20 serviços.', 422);
    foreach ($services as $service) if (!is_string($service) || trim($service) === '' || mb_strlen($service) > 150) fail('Serviço inválido.', 422);
    $out['category'] = $data['category'];
    $out['mode'] = $data['mode'];
    $out['services'] = json_encode(array_map('trim', $services), JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
    return $out;
}
