<?php
require __DIR__.'/../vendor/autoload.php';
$cfg=[];foreach(file(__DIR__.'/../.env') as $l)if(preg_match('/^\s*([\w.]+)\s*=\s*(.*?)\s*$/',$l,$m))$cfg[$m[1]]=trim($m[2],"\"'");
$db=new PDO('mysql:host='.($cfg['database.default.hostname']??'127.0.0.1').';charset=utf8mb4',$cfg['database.default.username']??'root',$cfg['database.default.password']??'root',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$backups=glob(__DIR__.'/../writable/backups/prd-*/banco.sql');sort($backups);$backup=end($backups);if(!$backup)throw new RuntimeException('Backup obrigatório.');
$test='portal_restauro_'.bin2hex(random_bytes(5));$db->exec("CREATE DATABASE `$test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
try{$db->exec("USE `$test`");$db->exec(file_get_contents($backup));$counts=json_decode(file_get_contents(dirname($backup).'/contagens.json'),true);foreach($counts as $table=>$count)if((int)$db->query("SELECT COUNT(*) FROM `$table`")->fetchColumn()!==$count)throw new RuntimeException('Falha no restauro: '.$table);echo "Backup restaurado e contagens verificadas.\n";}finally{$db->exec("DROP DATABASE `$test`");}
$target='portal_bairro_prd';$q=$db->prepare('SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=?');$q->execute([$target]);if($q->fetchColumn())throw new RuntimeException('A base destino já existe; não será sobrescrita.');
$db->exec("CREATE DATABASE `$target` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
$env=file_get_contents(__DIR__.'/../.env');file_put_contents(dirname($backup).'/.env.anterior',$env);$env=preg_replace('/^(\s*database.default.database\s*=).*$/m','$1 portal_bairro_prd',$env);file_put_contents(__DIR__.'/../.env',$env);echo "Base limpa preparada. Base anterior preservada.\n";
