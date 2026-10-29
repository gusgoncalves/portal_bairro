<?php
$root=dirname(__DIR__,2);$cfg=[];foreach(file($root.'/.env') as $l)if(preg_match('/^\s*([\w.]+)\s*=\s*(.*?)\s*$/',$l,$m))$cfg[$m[1]]=trim($m[2],"\"'");
$db=new PDO('mysql:host='.$cfg['database.default.hostname'].';dbname='.$cfg['database.default.database'].';charset=utf8mb4',$cfg['database.default.username'],$cfg['database.default.password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$b=json_decode(file_get_contents(__DIR__.'/backup-organizacao.json'),true);foreach($b['contagens'] as $t=>$n){if(!preg_match('/^[a-z_]+$/D',$t))throw new RuntimeException('Tabela inválida.');if((int)$db->query("SELECT COUNT(*) FROM `$t`")->fetchColumn()!==$n)throw new RuntimeException('Contagem mudou em '.$t);}
if($db->query("SHOW TABLES LIKE 'configuracoes_email'")->fetchColumn()!=='configuracoes_email')throw new RuntimeException('Atualização ausente.');echo "Dados anteriores preservados; tabela de SMTP disponível.\n";
