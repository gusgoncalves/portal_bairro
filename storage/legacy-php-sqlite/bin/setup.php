<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$root=dirname(__DIR__);
$storage=$root.'/storage';
if (!is_dir($storage)) mkdir($storage,0700,true);
$path=getenv('PORTAL_DB_PATH') ?: $storage.'/portal.sqlite';
if (is_file($path)) {echo "Banco existente preservado.\n";exit;}
$db=new PDO('sqlite:'.$path,null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$db->exec(file_get_contents($root.'/database/schema.sql'));
$db->beginTransaction();
$db->exec("INSERT INTO organizations(id,name) VALUES(1,'Gestão Vila Esperança'); INSERT INTO portals(id,organization_id,slug,name,capacity) VALUES(1,1,'vila-esperanca','Vila Esperança',10)");
$seed=json_decode(file_get_contents($root.'/database/seed.json'),true,512,JSON_THROW_ON_ERROR);
foreach($seed as $b) {
    $db->prepare('INSERT INTO advertisers(id,name) VALUES(?,?)')->execute([$b['id'],$b['name']]);
    $db->prepare('INSERT INTO publications(id,portal_id,advertiser_id,name,category,service,description,tags,color,accent,type,mode,hours,art,services,status) VALUES(?,1,?,?,?,?,?,?,?,?,?,?,?,?,?,?)')->execute([$b['id'],$b['id'],$b['name'],$b['category'],$b['service'],$b['description'],$b['tags'],$b['color'],$b['accent'],$b['type'],$b['mode'],$b['hours'],'',json_encode($b['services'],JSON_UNESCAPED_UNICODE),$b['status']]);
}
$credentials="ACESSOS LOCAIS — PORTAL DO BAIRRO\nContas de desenvolvimento. Não utilizar estas contas em produção.\n\n";
foreach ([['Master','master@portal.local','master','/admin',null],['Gestor','gestor@portal.local','manager','/gestor',null],['Anunciante','anunciante@portal.local','advertiser','/anunciantes',1]] as [$name,$email,$role,$route,$advertiser]) {
    $password=bin2hex(random_bytes(12));
    $db->prepare('INSERT INTO users(name,email,password_hash,role,advertiser_id) VALUES(?,?,?,?,?)')->execute([$name,$email,password_hash($password,PASSWORD_DEFAULT),$role,$advertiser]);
    $db->prepare('INSERT INTO memberships(user_id,portal_id) VALUES(?,1)')->execute([$db->lastInsertId()]);
    $credentials.="$name — http://localhost:8080$route\nE-mail: $email\nSenha: $password\n\n";
}
$db->commit();
file_put_contents(dirname($path).'/ACESSOS_LOCAIS.txt',$credentials,LOCK_EX);
echo "Banco criado com exemplos fictícios. Credenciais em storage/ACESSOS_LOCAIS.txt (acesso apenas pelo disco).\n";
