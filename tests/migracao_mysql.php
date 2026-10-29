<?php
require dirname(__DIR__).'/vendor/autoload.php';
use App\Libraries\MigradorNomesBanco;
use App\Libraries\NomesBanco;
$admin=new PDO('mysql:host=127.0.0.1;port=3306;charset=utf8mb4','root',getenv('MYSQL_TEST_PASSWORD')?:'', [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$name='portal_bairro_teste_pt_'.bin2hex(random_bytes(5));
if(!preg_match('/^portal_bairro_teste_pt_[0-9a-f]{10}$/D',$name))throw new RuntimeException('Nome inseguro.');
try{
 $sql=file_get_contents(dirname(__DIR__).'/storage/backups/banco-portugues/mysql.sql');$sql=str_replace('portal_bairro',$name,preg_replace('/^--.*$/m','',$sql));
 foreach(explode(';',$sql) as $statement)if(trim($statement)!=='')$admin->exec($statement);
 $db=new PDO('mysql:host=127.0.0.1;port=3306;dbname='.$name.';charset=utf8mb4','root',getenv('MYSQL_TEST_PASSWORD')?:'',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
 $db->exec("INSERT INTO organizations(id,name) VALUES(1,'Organização de teste'); INSERT INTO portals(id,organization_id,slug,name,capacity) VALUES(1,1,'teste','Nome com acentuação',10); INSERT INTO advertisers(id,name) VALUES(1,'Empresa de teste'); INSERT INTO users(id,name,email,password_hash,role,advertiser_id) VALUES(1,'Empresa','teste@teste.local','hash-teste','advertiser',1); INSERT INTO memberships VALUES(1,1); INSERT INTO publications(id,portal_id,advertiser_id,name,category,service,description,mode,hours,services,status) VALUES(1,1,1,'users name preservado','reformas','Serviço','Descrição','A domicílio','8h','[\"Serviço\"]','published'); INSERT INTO publication_revisions(id,publication_id,author_id,payload,status) VALUES(1,1,1,'{}','pending'); INSERT INTO revision_images(revision_id,filename,mime,slot,caption) VALUES(1,'teste.jpg','image/jpeg',1,'Fachada')");
 $directory=dirname(__DIR__).'/writable/test-runs/'.$name;
 $migration=new MigradorNomesBanco($db,$directory);$result=$migration->run();
 if(!$result['alterado']||!is_file($result['backup']))throw new RuntimeException('Backup ou migração ausente.');
 if($migration->run()['alterado'])throw new RuntimeException('Migração não idempotente.');
 $row=$db->query('SELECT nome FROM anuncios WHERE id=1')->fetch(PDO::FETCH_ASSOC);
 if($row['nome']!=='users name preservado')throw new RuntimeException('Conteúdo alterado.');
 if((int)$db->query('SELECT COUNT(*) FROM usuarios_portais')->fetchColumn()!==1)throw new RuntimeException('Vínculos perdidos.');
 try{$db->exec("INSERT INTO usuarios_portais(id_usuario,id_portal) VALUES(999,1)");throw new RuntimeException('Chave estrangeira não restaurada.');}catch(PDOException $e){if($e->getCode()!=='23000')throw $e;}
 try{$db->exec("UPDATE anuncios SET situacao='invalido' WHERE id=1");throw new RuntimeException('CHECK não restaurado.');}catch(PDOException $e){if(!in_array($e->getCode(),['23000','HY000'],true))throw $e;}
 $repo=new App\Models\PortalRepository($db);$api=$repo->one('SELECT name,status FROM publications WHERE id=?',[1]);
 if($api['name']!=='users name preservado'||$api['status']!=='published')throw new RuntimeException('Contrato API alterado.');
 echo "PASS: migração MySQL real, backup, nomes portugueses, dados, chaves, CHECKs, idempotência e compatibilidade API.\n";
}finally{
 // Apenas a base temporária criada neste teste. Nunca usa a base de trabalho.
 if(preg_match('/^portal_bairro_teste_pt_[0-9a-f]{10}$/D',$name))$admin->exec('DROP DATABASE IF EXISTS `'.$name.'`');
}
