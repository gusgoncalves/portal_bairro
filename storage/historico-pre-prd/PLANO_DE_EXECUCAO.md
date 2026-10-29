# Plano de execução — Portal do Bairro

## Entrega 1: demonstração estática

Implementada: início, listagem, perfil, explicação, participação, visão do gestor, gestão de anúncios e edição/criação demonstrativa.

Dados fictícios. Consulta pública. Sem exclusividade por categoria. Um perfil publicado ocupa um espaço, mesmo com vários serviços. Limite demonstrativo de 10 publicações. Suspensão libera espaço. Cadastro novo começa em análise. Alterações permanecem apenas na aba aberta.

## Validação com o líder

Registrar a tarefa realizada, se houve ajuda, dificuldade, comentário e decisão de ajuste. Testar com moradores e profissionais, além do gestor. Confirmar nome da região, limites de atendimento, categorias prioritárias, identidade e canais de divulgação. Usar dados reais somente com autorização.

Aceite proposto: encontrar serviço e contato sem orientação constante, compreender a oferta comercial e o gestor conseguir simular publicação e suspensão. Aprovação visual não comprova disposição a pagar.

## Entrega 2: fundação operacional

Definir stack e hospedagem. Implementar organizações, portais, usuários, vínculos de permissão e autenticação. Separar anunciante de publicação. Modelar assinaturas da plataforma e do anúncio separadamente. Verificar isolamento entre organizações no servidor. Banco relacional (PostgreSQL candidato), armazenamento de imagens e auditoria.

## Entrega 3: vitrine operacional

Cadastro, revisão, ativação com verificação transacional da capacidade, busca, imagens autorizadas, perfis públicos indexáveis e contato real. Manter revisão de alterações separada da versão publicada. Definir domínio e região de cada portal.

## Entrega 4: operação comercial e piloto

Cobrança inicialmente registrada manualmente. Formalizar vencimento, carência, suspensão, cancelamento e retenção antes de cobrar. Implementar indicadores distinguindo clique de contratação. Configurar backups e comprovar restauração. Piloto deve acompanhar um ciclo de cobrança e renovação.

## Posterior

Avaliações e moderação, favoritos, automação de cobrança, múltiplos domínios, PWA e aplicativos conforme evidências. Agendamento, pagamentos dos serviços e repasses não fazem parte do MVP inicial.

## Decisões ainda necessárias antes da produção

Responsável comercial e contrato; preços e inclusões; critérios de entrada de profissionais; política de dados; suporte; hospedagem e stack; prazo de regularização; critérios numéricos do piloto. Não há preços, cronograma ou receita garantidos.


## Atualização: fundação operacional iniciada

Stack implementada: PHP/PDO e API JSON; frontend HTML/CSS/JavaScript; SQLite local. O protótipo estático foi conectado à API. Não existe mais restauração de dados pela interface ou perda das alterações ao recarregar.

Implementados login por sessão, permissões master/gestor/anunciante, vínculos com portais, persistência e auditoria dos anúncios, validação no servidor e capacidade transacional. Painel master e área anunciante possuem consulta inicial; sua administração completa ainda não está concluída.

Próxima entrega: cadastro de usuários/portais e recuperação de acesso; depois, publicação com dados autorizados, upload de artes e revisão de alterações do anunciante. Cobrança, relatórios de interação e preparação de produção permanecem posteriores.


## Implementação atual — CodeIgniter e MySQL

A decisão de SQLite local foi substituída por MySQL conforme instrução do usuário. CodeIgniter 4 é o framework efetivo, instalado com dependências. Executar exclusivamente pela raiz `public` ou pelo iniciador. Fontes antigos estão preservados em `storage`.

Implementados catálogos, até três imagens por publicação, contatos WhatsApp/Instagram, edição do próprio anunciante, gestão de todas as empresas do portal, criação de acesso anunciante, criação de portais/gestores/master, capacidade, cobranças manuais, alteração de senha e auditoria.

As alterações de conteúdo feitas pelo anunciante são aplicadas diretamente, conforme operação atual. Publicar/suspender/arquivar permanece exclusivo do gestor/master. Revisão de alterações, recuperação por e-mail, métricas públicas, domínios personalizados e PWA instalável não estão implementados.

O MySQL real não pôde ser conectado no executor. Há SQL e instalador prontos; validação automatizada usa fixture isolada e não representa comprovação de transações concorrentes no MySQL.


## Decisão vigente: aprovação de todas as alterações

Substitui a regra anterior de edição direta. Empresa e administrador enviam propostas; apenas uma decisão explícita de administrador/gestor publica. Conteúdo aprovado permanece visível durante a revisão, incluindo fotos. Rejeição exige motivo; proposta alterada durante análise invalida uma aprovação antiga. O acesso inicial local admin/1234 é provisionado sem sobrescrever contas existentes. Tema aprovado integrado ao CodeIgniter; não houve alteração no Site demonstrativo hospedado.


## Atualização vigente — banco português e experiência de anúncio

A base MySQL local foi migrada efetivamente para tabelas e colunas em português, com backup e contagens preservadas. O instalador incorpora a migração retomável. O contrato JSON da API foi mantido para compatibilidade.

Na vitrine, a imagem abre o anúncio e o botão Instagram abre o perfil externo. A capa segue a mesma ordenação na vitrine, na edição e na prévia. As duas fotos adicionais abrem ampliadas em popup. Catálogos do gestor e da empresa possuem “Visualizar anúncio” no mesmo formato, sem a antiga navegação de página pública diferente. Validação por campo e conservação do formulário durante troca de imagens foram incluídas. Todas as alterações permanecem sujeitas à aprovação.
