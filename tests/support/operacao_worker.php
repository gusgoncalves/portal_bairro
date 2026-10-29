<?php
require __DIR__.'/../../vendor/autoload.php';
$name=$argv[1]??'';if(!preg_match('/^portal_prd_teste_[a-f0-9]{10}$/D',$name))throw new RuntimeException('Base inválida.');
$cfg=[];foreach(file(__DIR__.'/../../.env') as $l)if(preg_match('/^\s*([\w.]+)\s*=\s*(.*?)\s*$/',$l,$m))$cfg[$m[1]]=trim($m[2],"\"'");
$pdo=new PDO('mysql:host='.($cfg['database.default.hostname']??'127.0.0.1').';dbname='.$name.';charset=utf8mb4',$cfg['database.default.username']??'root',$cfg['database.default.password']??'');$repo=new App\Models\PortalRepository($pdo);
(new App\Libraries\OperacaoService($repo))->userAction(['id'=>3,'role'=>'manager'],1,2,['acao'=>'situacao','ativo'=>1]);
try{$repo->authorize(['id'=>2,'role'=>'advertiser'],2);throw new RuntimeException('A outra vitrine foi reativada indevidamente.');}catch(App\Libraries\BusinessException $e){if($e->status!==403)throw $e;}
echo 'Vínculo local reativado, outro vínculo preservado.';
