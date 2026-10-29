# Portal do Bairro — primeira fundação operacional

## Stack

- Backend: PHP 8.2+, PDO, sessões e API JSON.
- Frontend: HTML, CSS e JavaScript sem etapa de compilação.
- Banco local: SQLite, com chaves estrangeiras. PostgreSQL será avaliado para a hospedagem definitiva; ainda não existe suporte a ele nesta entrega.

## Iniciar localmente

Na pasta do projeto:

```powershell
php bin/setup.php
php -S localhost:8080 router.php
```

Abra http://localhost:8080. O setup preserva bancos existentes. Não abra mais o HTML diretamente: esta versão depende da API.

Os exemplos são fictícios. As contas são criadas com senhas aleatórias em `storage/ACESSOS_LOCAIS.txt`. Esse arquivo não é servido pelo roteador; abra-o diretamente no computador. Não publique nem envie essas credenciais.

- `/gestor`: login e gestão dos anúncios do portal vinculado.
- `/anunciantes`: login e consulta apenas dos próprios perfis.
- `/admin`: login master e visão dos portais e capacidades.

Não há links administrativos na página pública. Ocultar links não é o mecanismo de segurança: as permissões são verificadas também na API.

## Implementado

- Catálogo carregado do banco, busca e filtros no frontend.
- Login, logout, renovação do identificador de sessão e expiração após uma hora de inatividade.
- Senhas com hash, proteção CSRF e limitação de tentativas de login.
- Organizações, portais, usuários e vínculos de acesso separados.
- Anunciante separado de publicação; vínculo do usuário anunciante com seu negócio.
- Gestor cria, edita, aprova e suspende; ações persistem e são auditadas.
- Publicações novas começam em análise.
- Ativação e contagem de vagas ocorrem na mesma transação, respeitando a capacidade do portal.
- Consulta pública retorna somente perfis publicados; consultas restritas verificam papel e vínculo.
- Área master consulta portais; área do anunciante consulta seus perfis.
- Artes locais podem ser cadastradas em `artes/` e utilizadas como fachada do card.

## Validação

```powershell
python tests/integration.py
```

O teste usa PHP CGI e um banco temporário isolado em `storage/test-runs/`, sem alterar as contas de trabalho. Exercita API, sessões, permissões, isolamento entre portais, CSRF, validação, limite de vagas, auditoria e persistência. Não utiliza conexões de rede.

## Estrutura

- `backend/`: API, autorização e validação.
- `database/schema.sql`: estrutura SQLite inicial, sem senhas ou dados privados.
- `database/seed.json`: perfis fictícios.
- `bin/setup.php`: inicialização local idempotente.
- `storage/`: banco, credenciais locais e arquivos privados.
- `tests/`: integração executável.
- `index.html`, `styles.css`, `app.js`: interface.
- `router.php`: entrada do servidor local e lista explícita de arquivos públicos.

## Limites desta entrega

Servidor embutido PHP destinado ao desenvolvimento local. Não é implantação de produção.

Contatos, interesse em anunciar e denúncias ainda são explicativos. Não há cobranças, métricas de visitas, edição por anunciantes, fluxo de revisão de alterações, cadastro de usuários pelo painel, recuperação de senha, upload de imagens, criação de portais pelo painel ou PWA instalável. Os perfis iniciais são fictícios; não há avaliações inventadas.

O gestor edita diretamente os perfis sob sua gestão. A edição por anunciantes deverá passar por revisão em uma entrega posterior.

Antes de produção: definir hospedagem e HTTPS, rotinas de backup e restauração, gestão das credenciais, dados autorizados e política comercial. O roteamento documentado pressupõe acesso pela raiz de um host usando `router.php`, sem configuração pronta para subpastas Apache.

## Dados e continuidade

O esquema SQLite é a estrutura inicial, não um dump PostgreSQL. Banco e credenciais ficam excluídos do Git. Para testes, `PORTAL_DB_PATH` pode indicar outro arquivo; essa variável não representa migração automática de banco.

O documento original `Servicos_Bairro_Analise.md` foi preservado. O recorte atual segue a conversa: sem agendamento, intermediação financeira ou repasses nesta fase.
