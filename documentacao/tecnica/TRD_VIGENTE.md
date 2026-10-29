# TRD vigente — implementação econômica

- PHP com CodeIgniter 4: aproveita o sistema existente.
- MySQL/InnoDB: relacionamentos, transações e bloqueio por portal para operações concorrentes.
- Tabelas e colunas físicas em português; contrato JSON histórico mantido para compatibilidade.
- HTML/CSS/JavaScript responsivos: uma aplicação para computador e celular.
- Login por sessão, hash de senha, CSRF e limite de tentativas; senha alterada invalida sessões antigas.
- Separação de dados por portal e proprietário, verificada no servidor.
- Pagamentos externos com registros e baixas manuais; assinatura da plataforma separada das mensalidades dos anunciantes.
- Arquivos privados em disco e controladores de mídia; revisões não aprovadas não são públicas.
- Fila de e-mails via SMTP do CodeIgniter, com bloqueio de trabalho, tentativas e remoção do corpo após envio.
- Token aleatório armazenado como hash; links usam fragmento para não enviar token na URL ao servidor de páginas.
- E-mail normalizado identificado por HMAC para intervalo de avaliações; chave privada em configuração.
- Cliques armazenados sem IP bruto, com deduplicação por sessão; favoritos somente no navegador.
- Fonte Inter e licença distribuídas localmente; sem dependência de CDN para a interface.
- Hospedagem final ainda não contratada; necessária raiz public, HTTPS, MySQL, SMTP, tarefa agendada e backup externo.

## Defaults de implantação

Convite de avaliação: 7 dias (`portal.diasConvite`). Até 50 convites por anúncio em 24 horas. Recuperação: 1 hora. Ranking: peso 5 (`portal.pesoAvaliacao`) e nota-base 3 (`portal.notaBase`). São parâmetros de operação, ajustáveis antes do piloto; não representam pesquisa de mercado ou garantia de confiabilidade.

## Estrutura reaproveitada

O banco implementado reaproveita o catálogo e as revisões existentes, acrescentando assinaturas, períodos, pagamentos, convites, avaliações, eventos, tokens e fila. A capacidade fica no portal e o preço contratado na assinatura; não foi necessário um catálogo comercial separado de planos para operar o piloto. Arquivos de imagem continuam referenciados por nome entre versões, evitando duplicação física.


## Decisão vigente de cores

O briefing de tema escuro foi substituído a pedido do usuário. Restaurar o formato anterior: fundo claro `#F7F8FC`, cards e formulários brancos `#FFFFFF`, texto principal `#20263B`, texto secundário `#626B83`, roxo `#6250EC`, verde de contato `#059B73` e bordas claras `#DFE3EE`. Cabeçalho azul-marinho `#101627`, faixa de pesquisa escura e textos brancos sobre imagens permanecem como no layout anterior. Esta decisão altera somente cores: estrutura, tipografia, tamanhos, espaçamentos, cantos, telas e regras de negócio permanecem vigentes.


## Ajustes aprovados na validação de operação

- Acesso por ícone de usuário junto ao seletor de vitrine, com login em popup e encaminhamento automático por perfil; saudação distinta para master, gestor e anunciante.
- Endereço físico do portal aceita rua e número. O identificador do link é gerado automaticamente, sem exigir que o endereço siga um formato de URL.
- Identidade permite cor principal, cor do texto dos destaques e fonte; prévia imediata e ajuste automático do texto, sem bloquear combinações com mensagem técnica de contraste.
- Horários padronizados são cadastrados por vitrine pelo gestor, com dias da semana e início/fim. O anunciante seleciona um padrão ativo. Alterações em padrões não modificam automaticamente anúncios ou propostas já enviados.
- Visão geral do gestor mostra a soma real dos cliques em WhatsApp e Instagram no período selecionado; zero aparece como 0.
- Todos os itens de navegação indicam a seção ativa; a entrada passa a se chamar Novo anunciante. Bordas e foco dos campos usam tons suaves.
- Auditoria é exclusiva do master. O financeiro do master entrega apenas assinaturas dos gestores; o financeiro dos anunciantes é exclusivo de seu gestor e do próprio anunciante em consulta.
- Gestor lista somente usuários anunciantes vinculados à sua vitrine; pode ativar/inativar o vínculo, solicitar redefinição por e-mail ou definir senha provisória. Senhas existentes e hashes nunca são exibidos. Inativar acesso não libera vaga.
- Migração incremental em `AtualizarOperacao` preserva dados, importa horários existentes como padrões de transição e acrescenta os campos de identidade/endereço e estado do vínculo.


Estrutura acrescentada: `horarios_atendimento` (`id`, `id_portal`, `descricao`, `dias_semana`, `hora_inicio`, `hora_fim`, `ativo`); `portais` recebe `endereco_local`, `cor_texto` e `fonte`; `usuarios_portais` recebe `ativo`; `anuncios` recebe `id_horario`, mantendo `horario` como texto aprovado.

## Acesso por vitrine e operação na HostGator

Vitrines públicas não têm seletor de outros portais. Cada gestor compartilha seu link próprio; os painéis master e gestor oferecem acesso à página pública em nova aba. O painel master funciona sem portais cadastrados, desde que estrutura e usuário administrativo tenham sido instalados. `portal:install --sem-portal` inicializa essa modalidade. Tabelas/usuários ausentes exigem instalação pela CLI; não há criação automática de administrador por requisição pública. Rotas consideram a subpasta de app.baseURL.

SMTP usa a configuração privada e fila existente. Criação de gestor/master e anunciante prepara link individual de senha. Convites de avaliação incluem o identificador da vitrine. Aprovação/rejeição editorial não ganhou notificação automática nesta entrega. `portal:email-teste` enfileira mensagem de teste; `portal:emails` informa envios e falhas. Instruções de configuração e validação em DEPLOY_HOSTGATOR.md.

## Validação administrativa — datas, responsáveis e cadastros

Datas visíveis em pt-BR; auditoria em horário de Brasília e rótulos de ação em português, preservando os códigos originais no banco. Status financeiros padronizados: pendente amarelo, vencido vermelho, pago verde. Listagens privadas mostram os usuários responsáveis pelo acesso, sem expor esses dados na consulta pública.

Master edita portal e gestor; gestor edita e-mail de anunciante vinculado; Minha conta permite trocar e-mail mediante senha atual e mantém a troca de senha existente. Duplicidade de e-mail e redução de plano abaixo dos espaços ocupados são recusadas. Links anteriores de recuperação são invalidados ao mudar e-mail. Não foi adicionada confirmação do novo e-mail por mensagem. Gráficos por anunciante no popup do card Contatos gerados usam os dados e o período do relatório existente, com cores, legenda e contagem, inclusive estado zero.

## Organização e configuração de e-mails pelo master

A configuração SMTP é persistida na tabela configuracoes_email e administrada exclusivamente pelo master. Campos: id, servidor, porta, seguranca, usuario, senha_cifrada, remetente_email, remetente_nome, ativo, atualizado_por e atualizado_em. A senha usa AES-256-GCM e chave privada em writable/segredos; banco e chave devem ser preservados em backup privado. Os dados SMTP do .env deixam de ser usados; as configurações de banco/ambiente continuam no .env.

Mensagens autenticadas tentam envio depois do commit e retornam resultado para popup com ícone e texto de sucesso, pendência ou falha. Recuperação pública usa mensagem genérica e fila para não revelar contas existentes. Falha no transporte não desfaz cadastro salvo. A fila e o cron permanecem para recuperação e novas tentativas.

Minha conta usa formulário único, com nova senha opcional; alterar somente o e-mail não troca a senha. Botões de ação têm dimensões/espaçamentos padronizados. Cabeçalhos de saudação e catálogo exibem breadcrumb sem título visual repetido. O catálogo do anunciante usa Meu Anúncio. Total a receber e recebido do gestor são somas das cobranças exibidas por situação, sem intermediação de pagamento.

Documentos estão em documentacao/produto, documentacao/tecnica e documentacao/guias. Modelos e arquivos anteriores ficam em desenvolvimento. README.md é o índice da raiz. O pacote de produção exclui documentação, testes, ferramentas e materiais históricos.
