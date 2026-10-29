<?php
require __DIR__.'/../../vendor/autoload.php';
$name=$argv[1]??'';if(!preg_match('/^portal_prd_teste_[a-f0-9]{10}$/D',$name))throw new RuntimeException('Base inválida.');
$cfg=[];foreach(file(__DIR__.'/../../.env') as $l)if(preg_match('/^\s*([\w.]+)\s*=\s*(.*?)\s*$/',$l,$m))$cfg[$m[1]]=trim($m[2],"\"'");
$pdo=new PDO('mysql:host='.($cfg['database.default.hostname']??'127.0.0.1').';dbname='.$name.';charset=utf8mb4',$cfg['database.default.username']??'root',$cfg['database.default.password']??'');
$repo=new App\Models\PortalRepository($pdo);$user=['id'=>2,'role'=>'manager'];$portal=$repo->one('SELECT * FROM portals WHERE id=1');
try{
 if($argv[2]==='ocupar')$repo->transaction(function()use($repo,$argv){$p=$repo->lockPortal(1);$r=$repo->one('SELECT * FROM publications WHERE id=?',[(int)$argv[3]]);usleep(100000);(new App\Libraries\ComercialService($repo))->ocupar($r,$p);});
 elseif($argv[2]==='avaliar')(new App\Libraries\RelacionamentoService($repo))->avaliar(str_repeat($argv[3],64),['estrelas'=>5]);
 elseif($argv[2]==='pagar')(new App\Libraries\ComercialService($repo))->pagar($user,$portal,1);
 else throw new RuntimeException('Ação inválida.');
 echo json_encode(['status'=>200]);
}catch(App\Libraries\BusinessException $e){echo json_encode(['status'=>$e->status]);}
