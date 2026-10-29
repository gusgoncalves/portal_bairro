# Publicação na HostGator — Portal do Bairro

URL: https://annecont.com.br/portal/. Aplicação privada: /home1/anneco90/portal_bairro. Arquivos públicos: /home1/anneco90/public_html/portal. Preservar o index.php remoto que carrega /home1/anneco90/portal_bairro/app/Config/Paths.php. Não substituir .env nem arquivos do sistema em /sistema.

## Atualização de organização e SMTP

1. Fazer backup dos arquivos e do banco do Portal.
2. No phpMyAdmin, selecionar o banco do Portal e importar database/atualizacao_configuracoes_email.sql, fornecido no pacote. O script cria somente configuracoes_email se não existe e não apaga registros.
3. Extrair o ZIP de atualização em /home1/anneco90: portal_bairro contém os arquivos privados e public_html/portal contém os públicos. Enviar todos os arquivos juntos. O pacote não inclui index.php nem .env.
4. Recarregar o navegador. Os scripts recebem versão nova para evitar cache antigo.
5. Entrar como master e abrir Envio de e-mails.

O instalador php spark portal:install também cria/atualiza essa estrutura. Para contas iniciais sem vitrine, usar --sem-portal. Usuários administrativos nunca são criados por cadastro público automático.

## Configuração SMTP pelo master

Criar uma caixa real no cPanel, por exemplo portal@annecont.com.br, ou utilizar gustavo@annecont.com.br. Em Contas de e-mail > Conectar dispositivos consultar os dados reais do servidor.

No painel master > Envio de e-mails cadastrar: servidor, porta, segurança, usuário, senha, e-mail e nome do remetente e situação ativado/desativado. O servidor br464.hostgator.com.br foi visto no cPanel, mas confirmar se é o servidor dessa caixa. Para Titan usar os dados Titan apresentados pelo provedor.

Combinações usuais: SSL porta 465; TLS/STARTTLS porta 587. Não misturar os protocolos. Sem criptografia fica disponível para relay/testes que exijam esse modo; usar conexão segura na operação pela internet.

Salvar e executar Enviar e-mail de teste para uma caixa sua. Senha vazia em uma edição preserva a cadastrada. O navegador recebe somente a indicação de que há senha cadastrada, nunca a senha ou seu conteúdo cifrado.

As credenciais ficam em configuracoes_email. A senha é protegida por AES-256-GCM e a chave permanece em writable/segredos/smtp.key, fora da raiz pública e do repositório. Fazer backup privado do banco e dessa chave juntos. Se a chave for perdida, será necessário cadastrar a senha SMTP novamente. O .env continua necessário para o banco e URL, mas os antigos campos email.SMTP* não são utilizados pelo novo processador. Manter portal.chaveEmails existente para preservar os identificadores das avaliações; ela não é uma credencial de transporte SMTP.

## Envio e avisos

Cadastro de anunciante, criação de gestor/master, redefinição solicitada pelo gestor, convite de avaliação e teste SMTP: a mensagem é gravada e, depois do commit, o sistema tenta o envio. Aviso verde indica aceitação pelo servidor de saída; vermelho indica falha; amarelo indica que a mensagem está na fila por envio desativado/não configurado. Falha de SMTP não desfaz o cadastro já salvo, e repetir o cadastro pode duplicar a operação: corrigir SMTP e processar a fila.

A aceitação pelo SMTP não garante chegada na caixa de entrada. Conferir spam, SPF e DKIM em Entregabilidade de e-mail. Mensagens podem ser recusadas posteriormente pelo provedor do destinatário.

Esqueci minha senha: a resposta é sempre genérica, com aviso de solicitação recebida, sem revelar se o e-mail existe. Essas mensagens são processadas pela fila. A definição de nova senha não envia outra mensagem. O login inicial admin@portal.local não é um endereço real; testar com conta cadastrada com e-mail válido.

O reset expira em uma hora; convites de avaliação têm uso único e expiração configurada. O corpo da mensagem é removido da fila após envio. Há até cinco tentativas; falhas permanecem com mensagem de diagnóstico sem credenciais.

## Cron e terminal

Confirmar o caminho do PHP da conta. Para PHP 8.2 o caminho usual é /opt/cpanel/ea-php82/root/usr/bin/php. O cron da hospedagem compartilhada deve respeitar o intervalo permitido (documentação HostGator indica 15 minutos).

Minuto */15, demais campos *. Comando:

```sh
cd /home1/anneco90/portal_bairro && /opt/cpanel/ea-php82/root/usr/bin/php spark portal:emails >> /home1/anneco90/portal_bairro/writable/logs/cron-emails.log 2>&1
```

Para testar pelo painel não precisa Terminal. O teste do painel tenta enviar somente a mensagem criada pelo próprio pedido. O cron processa até 20 pendências por execução. Não criar endpoint público para disparar a fila.

## Conta, visual e financeiro

Minha conta reúne e-mail, senha atual e nova senha opcional; campos inalterados são preservados. Trocar e-mail ou senha invalida links antigos de recuperação, mantendo a sessão atual. Conta compartilhada usa o mesmo e-mail em todos os vínculos. O financeiro do gestor soma mensalidades pendentes/vencidas em Total a receber e baixas registradas em Total recebido; não representa conciliação bancária nem lucro.

Datas em dd/mm/aaaa; auditoria converte UTC armazenado para America/Sao_Paulo. A estrutura do banco mantém ISO. Status: pendente amarelo, vencido vermelho e pago verde, sempre acompanhados de texto. O gráfico de contatos usa o período do relatório e separa canais por empresa, sem contar cliques como vendas.

## Backup

Preservar banco, writable/uploads, writable/segredos e .env em armazenamento privado. Não publicar backups, documentação, modelos, testes ou ferramentas locais. Não copiar a chave SMTP para o GitHub.
