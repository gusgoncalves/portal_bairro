# Execução no XAMPP

## Inicialização

Inicie o MySQL no XAMPP e execute `iniciar.bat` na pasta do projeto. O instalador verifica a estrutura, traduz nomes antigos para português quando necessário e preserva contas e registros. O servidor local abre em http://localhost:8080.

Usuário inicial de administração: `admin`; senha inicial: `1234`. O instalador não redefinirá uma senha já alterada. A área da empresa é `/anunciantes`, com os acessos criados pelo administrador.

## Banco

A conexão fica em `.env`, fora da raiz pública. O esquema atual é `database/mysql.sql`. Para uma base antiga, prefira `php spark portal:install` antes de importar scripts manualmente: ele faz a tradução com backup e não cria tabelas paralelas vazias.

O backup anterior à tradução e seu estado ficam em `writable/migracoes/portal_bairro/`. A migração foi verificada em MariaDB 10.4.32, incluindo chaves estrangeiras e verificações, e aplicada à base local. Os nomes internos de índices já existentes são preservados para compatibilidade; tabelas e colunas usam nomes em português.

Não renomeie manualmente tabelas e colunas parcialmente: utilize a migração para manter o controle de integridade e de retomada.

## Apache

Use um VirtualHost cujo `DocumentRoot` seja `D:/Projeto/Portal do Bairro/public`. Ative `mod_rewrite` e `AllowOverride All`. Ajuste `app.baseURL` em `.env` ao endereço escolhido.

Não exponha a raiz do projeto, `writable`, `.env`, backups ou arquivos de teste.

## Imagens

JPG, PNG e WebP, até 5 MB por arquivo e até três imagens por versão. Configure o PHP do Apache com `upload_max_filesize=5M` e `post_max_size=20M`, reiniciando o Apache. O iniciador já aplica esses limites ao servidor embutido. `.user.ini` atende CGI/FastCGI, sem substituir o php.ini do mod_php.

Fotos pendentes são servidas apenas pela rota autenticada `revision-media/{id}`. As aprovadas usam `media/{id}`. Não mova o diretório privado de uploads para a raiz pública.

## Publicação

Use HTTPS, usuário MySQL específico e backup conjunto do banco e dos uploads antes de disponibilizar a instalação externamente. A senha inicial é destinada à configuração local. O endereço do Site demonstrativo não executa o backend PHP desta instalação.


## Versão PRD vigente

A conexão local ativa está em `portal_bairro_prd`; não executar scripts antigos para inserir demonstrações. O instalador provisiona apenas admin e vitrine Annecont vazia. Para instalação nova, configurar o banco no `.env` e executar `php spark portal:install`. O script `database/mysql.sql` representa a estrutura da versão nova; não executar sobre a base histórica com tabelas duplicadas. O iniciador preserva a base instalada.

Configurar SMTP com as opções de `.env.example` e agendar `php spark portal:emails` a cada minuto. Sem SMTP, o acesso por senha provisória funciona, mas convites e recuperação não chegam ao destinatário. Definir `app.baseURL` com HTTPS no domínio definitivo antes de enviar links. Trocar senha inicial e usar usuário de banco próprio antes de exposição externa. Publicar somente `public`.

A restauração do backup anterior foi conferida. Para operação real, ainda configurar backup diário do banco e imagens com cópia fora da máquina e testar restauração periodicamente.
