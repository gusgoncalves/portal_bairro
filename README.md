# Portal do Bairro

Vitrines de empresas e serviços em CodeIgniter 4, PHP 8.2+ e MySQL. Não há venda de produtos nem intermediação de pagamentos.

## Operação

- app/: aplicação e regras de negócio.
- public/: única pasta acessível pela web.
- database/: esquema SQL e atualizações incrementais; nomes físicos em português.
- writable/: imagens, sessões, logs, backups e chave privada do SMTP.
- vendor/: dependências instaladas por Composer.
- .env: conexão ao banco, URL e ambiente; credenciais SMTP são cadastradas pelo master no painel.
- spark: comandos administrativos e processamento da fila de e-mails.

## Apoio, separado da aplicação

- documentacao/: produto, técnica, guias e histórico.
- desenvolvimento/: modelos e materiais antigos.
- tests/: verificações automatizadas com bancos descartáveis.
- storage/: ferramentas locais, metadados de versionamento e pacotes de entrega; não publicar.

## Iniciar localmente

Configurar .env a partir de .env.example, iniciar o MySQL e executar iniciar.bat. O instalador preserva contas e dados. Em instalação nova, trocar imediatamente a senha administrativa inicial. Para começar sem vitrine: php spark portal:install --sem-portal.

## Publicação e e-mails

Consultar documentacao/guias/DEPLOY_HOSTGATOR.md. A aplicação da Annecont usa /portal e fica separada de /sistema. O master configura SMTP em Envio de e-mails; TLS/STARTTLS, SSL e conexão sem criptografia são opções explícitas. O cron php spark portal:emails processa pendências. Envios autenticados tentam enviar após a gravação e mostram resultado; recuperação pública permanece na fila com mensagem genérica para proteger a existência da conta.

## Verificação

python tests/integration.py; node tests/frontend.cjs; python tests/browser_prd.py; python tests/smtp_prd.py; python tests/concorrencia_prd.py. Os testes criam bases temporárias, não substituem a base operacional.

PRD: documentacao/produto/PRD_VIGENTE.md. TRD: documentacao/tecnica/TRD_VIGENTE.md. As decisões de negócio permanecem nesses documentos.
