# Plano vigente — PRD e TRD

Piloto Annecont, vitrine pública, contratação direta.
- Gestor paga assinatura por capacidade a partir da liberação do acesso.
- Empresa ocupa espaço a partir da liberação do acesso; suspensão não libera vaga.
- Empresa paga mensalidade individual a partir da primeira publicação aprovada.
- Conteúdo e imagens sempre passam por aprovação; rejeição e despublicação exigem motivo.
- Período vencido sinaliza pendência e não retira anúncio automaticamente.
- Pagamentos e renovações manuais, sem gateway, agenda, repasses ou chat.
- Avaliações por convite individual, intervalo de 24h por e-mail e empresa.
- Métricas representam cliques, não contratação confirmada.

Documentos anteriores preservados em storage/historico-pre-prd.
Consultar IMPLEMENTACAO_PRD.md para estado e testes.


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
