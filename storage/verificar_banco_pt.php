<?php
require dirname(__DIR__).'/vendor/autoload.php';
$p=new PDO('mysql:host=127.0.0.1;port=3306;dbname=portal_bairro;charset=utf8mb4','root',getenv('MYSQL_TEST_PASSWORD'),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$m=App\Libraries\NomesBanco::mapa();$state=json_decode(file_get_contents(dirname(__DIR__).'/writable/migracoes/portal_bairro/estado.json'),true);
foreach($state['contagens'] as $old=>$expected){$table=$m['tabelas'][$old]??$old;$count=(int)$p->query('SELECT COUNT(*) FROM `'.$table.'`')->fetchColumn();if($count!==$expected)throw new RuntimeException('Contagem divergente '.$table);}
$tables=$p->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
if(array_intersect(array_keys($m['tabelas']),$tables))throw new RuntimeException('Tabela antiga permanece.');
foreach(array_values($m['tabelas']) as $table){$cols=$p->query('SHOW COLUMNS FROM `'.$table.'`')->fetchAll(PDO::FETCH_COLUMN);if(array_intersect(array_keys($m['colunas']),$cols))throw new RuntimeException('Coluna antiga em '.$table);}
echo 'PASS: base real em português; '.count($tables).' tabelas; contagens preservadas; backup '.(is_file($state['backup'])?'presente':'ausente').PHP_EOL;
