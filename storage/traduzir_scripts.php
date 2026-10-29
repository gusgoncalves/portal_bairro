<?php
require dirname(__DIR__).'/vendor/autoload.php';
foreach(['mysql.sql','admin_inicial.sql','upgrade_aprovacoes.sql'] as $file){$path=dirname(__DIR__).'/database/'.$file;file_put_contents($path,App\Libraries\NomesBanco::sql(file_get_contents($path)));}
