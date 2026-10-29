<?php
$cfg=[];foreach(file(__DIR__.'/../.env') as $l)if(preg_match('/^\s*([\w.]+)\s*=\s*(.*?)\s*$/',$l,$m))$cfg[$m[1]]=trim($m[2],"\"'");
$name=$cfg['database.default.database']??'';if($name!=='portal_bairro_prd')throw new RuntimeException('Base ativa inesperada.');
$db=new PDO('mysql:host='.($cfg['database.default.hostname']??'127.0.0.1').';dbname='.$name.';charset=utf8mb4',$cfg['database.default.username']??'root',$cfg['database.default.password']??'root',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$counts=[];foreach(['anuncios','anunciantes','usuarios','portais','cobrancas','assinaturas','fila_emails'] as $t)$counts[$t]=(int)$db->query("SELECT COUNT(*) FROM `$t`")->fetchColumn();
if($counts!==['anuncios'=>0,'anunciantes'=>0,'usuarios'=>1,'portais'=>1,'cobrancas'=>0,'assinaturas'=>0,'fila_emails'=>0])throw new RuntimeException('A base operacional não está vazia como esperado: '.json_encode($counts));
$tables=$db->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);foreach(['users','publications','portals','organizations'] as $old)if(in_array($old,$tables))throw new RuntimeException('Tabela antiga encontrada.');
echo json_encode(['base'=>$name,'tabelas'=>count($tables),'contagens'=>$counts,'vitrine'=>$db->query('SELECT nome,identificador FROM portais')->fetchAll(PDO::FETCH_ASSOC)],JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT);
