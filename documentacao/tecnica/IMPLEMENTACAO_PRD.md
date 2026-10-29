# Implementação alinhada ao PRD

## Entregue

- Escopo vigente consolidado; propostas históricas arquivadas.
- Base operacional limpa `portal_bairro_prd`, somente tabelas em português; base anterior preservada e backup restaurado/conferido.
- Instalação sem demonstrações: uma vitrine Annecont vazia e administrador local.
- Capacidade por acesso liberado, planos com limite numérico configurável, sem liberar espaço por suspensão.
- Cadastro mínimo com empresa, responsável, mensalidade e liberação de acesso na mesma transação.
- Mensalidade individual, dias por período, primeira cobrança/publicação atômicas, renovação manual sem sobreposição e pagamento idempotente com histórico.
- Assinatura do gestor iniciada na criação de seu primeiro acesso; cobrança e renovação da plataforma restritas ao master.
- Motivo obrigatório para suspensão e arquivamento; visível ao anunciante.
- Aprovação de textos e imagens preservada, comparação e rejeição com motivo.
- Prévia, até três imagens, adição individual, arraste e identificação das posições.
- Recuperação e definição de senha, fila SMTP e links temporários de uso único.
- Convites de avaliação, estrelas reais, intervalo de 24h, ranking ponderado e consulta dos convites.
- Métricas por anúncio/canal/período e favoritos locais.
- Identidade por nome, cor e URL HTTPS do logotipo; paleta clara anterior restaurada e fonte Inter local.

## Limites e configuração antes do uso externo

- Configurar remetente e credenciais SMTP reais e agendar `portal:emails`; validação do envio foi feita com SMTP local.
- Logotipo por URL HTTPS nesta entrega; não existe um uploader próprio de logotipos.
- Assinatura criada na primeira liberação do gestor; desbloqueio posterior não cria outra assinatura. Transferências entre gestores e alteração da organização de um portal ficam fora desta entrega.
- A senha provisória é definida pelo gestor; também existe convite para o usuário definir a própria senha.
- Não há comprovação automática de que o serviço avaliado aconteceu.
- Não há liberação de vaga por encerramento até fechar a regra comercial; suspensão e arquivamento mantêm reserva.
- Hospedagem externa, rotinas diárias de backup, política de retenção e metas do piloto ainda precisam de definição operacional.

## Verificação

Os testes CGI usam fixture descartável e os testes de navegador/concorrência/SMTP criam bancos MySQL com nomes exclusivos, conferem a base inicial e a removem ao final. Nenhum e-mail de teste é enviado para destinatário externo.

Um ajuste no suporte Windows passou a importar explicitamente as configurações de banco e SMTP dos testes, impedindo que o arquivo local substitua o banco temporário. Dados fictícios da validação inicial foram removidos da base operacional, preservando admin e vitrine. O teste de navegador também identificou e corrigiu um render duplo e a inicialização de proposta sobre cadastro ainda vazio.


### Resultado da verificação local

- 165 verificações CGI aprovadas, incluindo isolamento, propostas, cobrança, renovação, pagamento, avaliação e recuperação.
- 64 combinações de papel/rota renderizadas, com verificações adicionais do módulo PRD.
- Chrome real com MySQL descartável: fluxo completo e larguras de 320px e 390px.
- Concorrência MySQL entre processos PHP: última vaga, consumo do convite, intervalo por e-mail e pagamento idempotente.
- SMTP local: mensagem enviada, uma tentativa bem-sucedida e remoção do corpo após envio.
- Base operacional verificada: 22 tabelas portuguesas, zero anunciantes/anúncios/cobranças/assinaturas, uma vitrine e um administrador.
- Primeira publicação não pode ser contornada suspendendo e reativando um cadastro ainda não aprovado.


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


### Aceite dos ajustes operacionais

203 verificações CGI, 64 renderizações em VM, fluxo completo em Chrome/MySQL isolado, concorrência e SMTP local aprovados. O teste real cobre endereço com rua/número, cores de fundo e texto independentes, fonte, cadastro/seleção de horários, gestão de acesso, estados ativos dos menus, contagem de cliques e separação financeira por papel. A migração foi executada sem recriar ou limpar a base em uso.

Bloqueios legados de contas anunciantes foram convertidos em bloqueios dos respectivos vínculos, mantendo todos os acessos antes bloqueados. O gestor pode reativar somente o vínculo da própria vitrine. O cadastro global do master mantém gestores e administradores separados dos anunciantes.

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
