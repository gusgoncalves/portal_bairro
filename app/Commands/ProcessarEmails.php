<?php
namespace App\Commands;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use App\Libraries\EmailService;
use App\Models\PortalRepository;
final class ProcessarEmails extends BaseCommand {
 protected $group='Portal';protected $name='portal:emails';protected $description='Processa a fila usando SMTP configurado pelo master.';
 public function run(array $params){$r=(new EmailService(new PortalRepository()))->process();CLI::write('Fila processada: '.$r['enviados'].' enviado(s), '.$r['falhas'].' falha(s).');if($r['status']!=='enviado')CLI::write($r['message']);return $r['status']==='falha'?EXIT_ERROR:EXIT_SUCCESS;}
}
