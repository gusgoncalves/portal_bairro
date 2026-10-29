<?php
declare(strict_types=1);
require __DIR__ . '/bootstrap.php';
ini_set('display_errors', '0');
session_name('portal_session');
session_start(['use_strict_mode'=>true, 'cookie_httponly'=>true, 'cookie_samesite'=>'Strict', 'cookie_secure'=>(!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'), 'cookie_path'=>'/']);

try {
    $method = $_SERVER['REQUEST_METHOD'];
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $user = currentUser();
    $_SESSION['csrf'] ??= bin2hex(random_bytes(32));
    if ($method !== 'GET') csrf();
    if ($path === '/api/session' && $method === 'GET') respond(['user'=>$user, 'csrf'=>$_SESSION['csrf']]);
    if ($path === '/api/login' && $method === 'POST') {
        $data = body();
        $email = is_string($data['email'] ?? null) ? mb_strtolower(trim($data['email'])) : '';
        $password = is_string($data['password'] ?? null) ? $data['password'] : '';
        $fingerprint = hash('sha256', ($_SERVER['REMOTE_ADDR'] ?? '') . '|' . $email);
        query('DELETE FROM login_attempts WHERE attempted_at < ?', [time()-900]);
        $attempts = (int) query('SELECT COUNT(*) FROM login_attempts WHERE fingerprint=?', [$fingerprint])->fetchColumn();
        $ipKey = hash('sha256', $_SERVER['REMOTE_ADDR'] ?? 'local');
        $ipAttempts = (int) query('SELECT COUNT(*) FROM login_attempts WHERE fingerprint=?', [$ipKey])->fetchColumn();
        if ($attempts >= 5 || $ipAttempts >= 30) fail('Muitas tentativas. Aguarde 15 minutos.', 429);
        query('INSERT INTO login_attempts(fingerprint,attempted_at) VALUES(?,?),(?,?)', [$fingerprint,time(),$ipKey,time()]);
        $account = query('SELECT * FROM users WHERE email=?', [mb_substr($email,0,254)])->fetch();
        $dummy = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi';
        $valid = password_verify(substr($password,0,1024), $account['password_hash'] ?? $dummy);
        if (!$account || !$valid || strlen($password)>1024) fail('E-mail ou senha incorretos.', 401);
        session_regenerate_id(true);
        $_SESSION['user_id'] = $account['id'];
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
        $_SESSION['last_seen'] = time();
        query('DELETE FROM login_attempts WHERE fingerprint=?', [$fingerprint]);
        respond(['user'=>currentUser(), 'csrf'=>$_SESSION['csrf']]);
    }
    if ($path === '/api/logout' && $method === 'POST') {
        $_SESSION = [];
        session_regenerate_id(true);
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
        respond(['user'=>null,'csrf'=>$_SESSION['csrf']]);
    }
    if ($path === '/api/admin/portals' && $method === 'GET') {
        if (!$user) fail('Entre na sua conta.',401);
        if ($user['role'] !== 'master') fail('Acesso não permitido.',403);
        respond(['portals'=>query('SELECT p.id,p.name,p.slug,p.capacity,o.name AS organization,(SELECT COUNT(*) FROM publications a WHERE a.portal_id=p.id AND a.status=\'published\') AS active FROM portals p JOIN organizations o ON o.id=p.organization_id')->fetchAll()]);
    }
    $slug = $_GET['portal'] ?? 'vila-esperanca';
    if (!is_string($slug) || strlen($slug)>100) fail('Portal inválido.',400);
    $portal = query('SELECT id,name,slug,capacity FROM portals WHERE slug=?', [$slug])->fetch();
    if (!$portal) fail('Portal não encontrado.',404);
    $portalId = (int) $portal['id'];
    if ($path === '/api/publications' && $method === 'GET') {
        $scope = $_GET['scope'] ?? 'public';
        $sql = 'SELECT * FROM publications WHERE portal_id=?'; $params=[$portalId];
        if ($scope === 'manage') authorize($user,$portalId,true);
        elseif ($scope === 'mine') {
            authorize($user,$portalId);
            if ($user['role'] !== 'advertiser') fail('Área exclusiva do anunciante.',403);
            $sql .= ' AND advertiser_id=?'; $params[]=$user['advertiser_id'];
        } elseif ($scope === 'public') $sql .= " AND status='published'";
        else fail('Consulta inválida.',400);
        respond(['portal'=>$portal,'publications'=>array_map('publicPublication',query($sql.' ORDER BY id',$params)->fetchAll())]);
    }
    if ($path === '/api/publications' && $method === 'POST') {
        authorize($user,$portalId,true); $data=validatePublication(body());
        db()->beginTransaction();
        query('INSERT INTO advertisers(name) VALUES(?)',[$data['name']]); $advertiserId=(int)db()->lastInsertId();
        $data += ['portal_id'=>$portalId,'advertiser_id'=>$advertiserId,'status'=>'pending'];
        $columns=array_keys($data);
        query('INSERT INTO publications('.implode(',',$columns).') VALUES('.implode(',',array_fill(0,count($columns),'?')).')',array_values($data));
        $id=(int)db()->lastInsertId();
        query('INSERT INTO audit_logs(user_id,portal_id,action,publication_id) VALUES(?,?,?,?)',[$user['id'],$portalId,'publication.created',$id]);
        db()->commit(); respond(['id'=>$id],201);
    }
    if (preg_match('~^/api/publications/(\d+)(/status)?$~',$path,$matches) && in_array($method,['PUT','POST'],true)) {
        authorize($user,$portalId,true); $id=(int)$matches[1];
        // Serializa a contagem e ativação para impedir ultrapassagem concorrente.
        db()->exec('BEGIN IMMEDIATE');
        $row=query('SELECT * FROM publications WHERE id=? AND portal_id=?',[$id,$portalId])->fetch();
        if (!$row) { db()->exec('ROLLBACK'); fail('Publicação não encontrada.',404); }
        if (!empty($matches[2]) && $method==='POST') {
            $status=body()['status']??null;
            if (!in_array($status,['published','suspended'],true)) {db()->exec('ROLLBACK');fail('Situação inválida.',422);}
            if ($status==='published' && $row['status']!=='published') {
                $count=(int)query("SELECT COUNT(*) FROM publications WHERE portal_id=? AND status='published'",[$portalId])->fetchColumn();
                if ($count >= (int)$portal['capacity']) {db()->exec('ROLLBACK');fail('Limite de espaços atingido.',409);}
            }
            query('UPDATE publications SET status=?,updated_at=CURRENT_TIMESTAMP WHERE id=? AND portal_id=?',[$status,$id,$portalId]);
            $action='publication.'.$status;
        } elseif (empty($matches[2]) && $method==='PUT') {
            $data=validatePublication(body());
            $sets=array_map(fn($key)=>$key.'=?',array_keys($data));
            query('UPDATE publications SET '.implode(',',$sets).',updated_at=CURRENT_TIMESTAMP WHERE id=? AND portal_id=?',[...array_values($data),$id,$portalId]);
            $action='publication.updated';
        } else {db()->exec('ROLLBACK');fail('Método inválido.',405);}
        query('INSERT INTO audit_logs(user_id,portal_id,action,publication_id) VALUES(?,?,?,?)',[$user['id'],$portalId,$action,$id]);
        db()->exec('COMMIT');respond(['ok'=>true]);
    }
    fail('Endpoint não encontrado.',404);
} catch (Throwable $e) {
    if (isset($connection) && $connection->inTransaction()) $connection->rollBack();
    error_log((string)$e);
    fail('Não foi possível concluir a operação. Consulte o registro do servidor.',500);
}
