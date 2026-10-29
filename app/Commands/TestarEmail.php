<?php
namespace App\Commands;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use App\Models\PortalRepository;
use App\Libraries\RelacionamentoService;
final class TestarEmail extends BaseCommand
{
 protected $group='Portal';
 protected $name='portal:email-teste';
 protected $description='Coloca um e-mail de teste na fila privada; execute portal:emails para enviar.';
 public function run(array $params){
  $email=$params[0]??'';
  if(!filter_var($email,FILTER_VALIDATE_EMAIL)){CLI::error('Informe o destinatário: php spark portal:email-teste destinatario@exemplo.com');return EXIT_ERROR;}

  try{(new RelacionamentoService(new PortalRepository()))->email($email,'Teste de envio - Portal do Bairro','Este é um teste de envio do Portal do Bairro. Nenhum cadastro ou senha foi alterado.');
   CLI::write('Teste adicionado à fila. Execute php spark portal:emails. Enfileirar não confirma a entrega.','green');return EXIT_SUCCESS;
  }catch(\Throwable $e){CLI::error('Não foi possível preparar o teste. Confira a instalação e o banco.');return EXIT_ERROR;}
 }
}
