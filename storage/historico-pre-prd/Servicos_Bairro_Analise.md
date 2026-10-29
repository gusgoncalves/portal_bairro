# Mural Digital de Serviços Locais: Análise de Negócio e Sistema

Documento de análise de negócios e de sistemas. Versão 2.0, 22/10/2026.

## 1. Visão e proposta de valor

**Conceito:** um mural digital local. Qualquer comunidade ou ponto com grande circulação de pessoas ganha uma vitrine de serviços acessada por QR code ou link. Cada vitrine é um "mural" independente, com seu administrador.

**Problema:** quem circula nesses lugares não conhece os prestadores que estão perto, e os prestadores locais (em geral MEIs) não têm divulgação organizada.

**Solução:** catálogo curado pelo administrador do mural, com anúncios programados por período, contato direto (WhatsApp, Instagram) e uma subpágina por anúncio com fotos, qualificações e lista de agendamento.

**Diferencial frente ao OLX/Google:** curadoria local, custo fixo sem pagar por contato e presença nos lugares onde as pessoas já circulam.

| Tipo de mural | Quem administra | Quem anuncia | Quem vê |
| --- | --- | --- | --- |
| Bairro | Representante ou associação de moradores | MEIs do bairro (pedreiro, manicure, barbeiro, cozinheira) | Moradores |
| Escritório de contabilidade | O próprio escritório | Clientes MEI e ME | Demais clientes e empresas atendidas |
| Mercadinho | Dono ou gerente | Prestadores da região | Clientes da loja, com QR code no caixa |
| Condomínio | Síndico | Prestadores que atendem os moradores | Moradores |

## 2. Atores

| Ator | Papel |
| --- | --- |
| Master (você) | Gerencia murais, planos, licenças e cobranças. Assume a gestão de um mural quando o administrador fica inadimplente ou sai, e pode substituí-lo |
| Administrador do mural | Curador local: cadastra anunciantes e anúncios, define a programação de cada um e cobra o aluguel quando o arranjo de cobrança prevê isso |
| Anunciante (MEI ou ME) | Tem anúncio e subpágina; na fase posterior edita o próprio conteúdo e a própria agenda |
| Visitante | Chega pelo QR code ou link, navega, busca, contata, agenda e avalia, sem cadastro inicial |

## 3. Modelo de receita

A receita nasce do aluguel do espaço no mural, e o sistema deve aceitar três arranjos de cobrança sem mudar a estrutura.

| Arranjo | Quem paga a quem | Vantagem | Risco |
| --- | --- | --- | --- |
| A. Licença do administrador | O administrador paga ao master uma licença por faixa de vagas (10, 50, 100, 200+) e cobra o aluguel dos anunciantes | Receita previsível e divulgação feita por quem conhece o local | O master depende da cobrança e da divulgação do administrador |
| B. Venda direta | O anunciante paga a assinatura do anúncio direto ao master, sem mediador | Maior margem e controle total da base | Exige esforço comercial e suporte do master |
| C. Híbrido com comissão | O anunciante paga ao master, que repassa um percentual ao administrador | Alinha o interesse do administrador sem ele cobrar ninguém | Exige controle financeiro dos repasses |

**Recomendação:** registrar o pagador em cada anúncio, para que A, B e C convivam no mesmo sistema. No piloto, usar A onde houver um administrador de confiança (o administrador do bairro, escolhido pelo conhecimento local) e B onde o master vender direto.

**Cobrança por período:** o anúncio é programado com início e fim e vendido em planos mensal, trimestral, semestral ou anual, com desconto crescente. Os valores ficam a definir no piloto.

**Privilégio de exibição:** por enquanto todos os anúncios têm o mesmo privilégio. O destaque pago fica para uma fase futura, depois de validada a receita base.

**Receitas futuras:** destaque pago, banners, taxa de implantação, white-label e taxa sobre agendamentos.

**Hipótese de lucratividade a validar:** nichos que já têm relacionamento recorrente com MEIs e MEs, como o escritório de contabilidade, tendem a ter menor custo de aquisição de anunciantes que o bairro.

## 4. Módulos do sistema

### A. Painel Master

- Cadastro de murais com tipo (bairro, escritório, comércio, condomínio) e responsável
- Planos, faixas de vagas, licenças, vencimentos e inadimplência
- Assumir a gestão de um mural: suspender o acesso do administrador, manter os anúncios no ar e substituí-lo, com histórico
- Venda direta de anúncios, sem mediador
- Dashboard global (murais ativos, receita, anúncios)

### B. Painel do Administrador

- Cadastro de anunciantes e anúncios
- Programação do anúncio: data de início, data de fim, renovação e aviso de vencimento
- Gestão de categorias e controle de vagas usadas, com alerta de limite e botão de upgrade
- Controle do aluguel dos anunciantes (vencimento, status, histórico)
- Moderação (ativar, suspender)

### C. Portal Público (web e mobile)

- Entrada por QR code ou link curto de cada mural
- Home com cards quadrados de categorias, no formato de cardápio
- Busca por nome, serviço e palavra-chave, e listagem por categoria
- Página do anúncio com botões diretos para WhatsApp, Instagram e rota no mapa
- Favoritos e avaliações (fase posterior)

### D. Subpágina do anúncio

- Galeria de fotos dos serviços
- Qualificações e certificados do prestador
- Lista de serviços, com preço opcional
- Lista de agendamento: o visitante pede um horário e o anunciante confirma. Sem pagamento online no MVP

### E. Transversais

- Autenticação e permissões por perfil
- Rotinas automáticas: expirar anúncios vencidos, avisar vencimentos e aplicar a suspensão por inadimplência
- Notificações por WhatsApp e e-mail
- Métricas por anúncio (visualizações e cliques) e relatórios

## 5. Arquitetura (visão de sistemas)

- **Multi-tenant por mural:** um sistema, vários murais, com dados isolados por identificador de mural. Cada mural tem URL própria e QR code.
- **Tema por tipo de mural:** textos e categorias pré-configurados para bairro, contabilidade, comércio e condomínio, o que reduz o trabalho de implantar um novo nicho.
- **API central:** web e mobile consomem o mesmo back-end.
- **Mobile:** começar com PWA (web instalável); app nativo só depois de validar o negócio.
- **Rotinas agendadas:** vigência dos anúncios, avisos de vencimento e suspensão por inadimplência rodam automaticamente.
- **Armazenamento de imagens:** separado do banco, com compressão automática. A subpágina aumenta o volume de fotos.
- **SEO:** páginas públicas indexáveis, pois "encanador + bairro" no Google é canal gratuito de aquisição.
- **LGPD e sigilo:** consentimento do anunciante para divulgar seus dados. No mural de escritório de contabilidade, nenhum dado de cliente é exposto sem consentimento.

## 6. Estrutura de banco de dados (conceitual)

### Núcleo multi-tenant

- **murais:** nome, tipo (bairro, escritório, comércio, condomínio), cidade, UF, slug, logo, cores, status, administrador atual
- **planos:** nome, limite de vagas, valor, periodicidade
- **licencas:** mural, plano, início, vencimento, status
- **usuarios:** nome, e-mail, senha, perfil (master/admin/anunciante/visitante), mural
- **gestao\_historico:** mural, administrador anterior, novo administrador, motivo (inadimplência, saída), data, quem executou

### Catálogo

- **categorias:** mural, nome, ícone, ordem, ativa
- **anunciantes:** mural, razão/nome, CNPJ (MEI ou ME), responsável, telefone, status
- **anuncios:** anunciante, categoria, título, descrição, tags e sinônimos de busca, WhatsApp, Instagram, endereço, latitude/longitude, horário, modo de atendimento (domicílio, no local ou ambos), status
- **anuncio\_periodos:** anúncio, data de início, data de fim, plano contratado, renovação automática, status (programado, ativo, vencido)
- **anuncio\_midias:** anúncio, tipo (foto/vídeo), caminho, ordem
- **anuncio\_servicos:** anúncio, serviço, descrição, preço (opcional)
- **anuncio\_qualificacoes:** anúncio, título, instituição, ano, comprovante (opcional)

### Agenda

- **agenda\_horarios:** anúncio, dia da semana, hora inicial, hora final, capacidade
- **agendamentos:** anúncio, visitante (nome e telefone), data e hora pedidas, status (pedido, confirmado, recusado, cancelado)

### Financeiro

- **cobrancas:** referência (licença ou período de anúncio), pagador (administrador, anunciante), valor, vencimento, pagamento, status
- **repasses:** cobrança, beneficiário (administrador), percentual, valor, status. Usado apenas no arranjo híbrido
- **historico\_vagas:** controle de ocupação por mural

### Engajamento

- **avaliacoes:** anúncio, visitante verificado, nota, comentário, status de moderação
- **favoritos:** visitante, anúncio
- **metricas:** anúncio, tipo de evento (visualização, clique WhatsApp, clique Instagram, pedido de agendamento), data
- **logs\_auditoria:** quem fez o quê e quando

### Regras críticas

- Todo registro carrega o identificador do mural.
- A vaga ocupada é calculada por anúncios com período ativo contra o limite da licença.
- Anúncio com período vencido sai da vitrine automaticamente.
- Licença vencida suspende o acesso do administrador, mas não altera o status dos anúncios nem o acesso público. O master passa a operar o mural e registra a troca em gestao\_historico.

## 7. Cronograma lógico

| Fase | Duração estimada | Entregas |
| --- | --- | --- |
| 0. Validação | 2 a 3 semanas | Piloto manual em dois tipos de mural (por exemplo, bairro e escritório de contabilidade ou mercadinho). Teste de preços e escolha do arranjo de cobrança A, B ou ambos |
| 1. Análise e design | 3 semanas | Requisitos fechados, regras de negócio, protótipo de telas (home, anúncio, subpágina, painéis), modelagem de banco, identidade visual |
| 2. Fundação | 3 a 4 semanas | Multi-tenant por mural, autenticação, perfis, painel Master (murais, planos, licenças) e regra de suspensão e substituição do administrador |
| 3. MVP do administrador | 4 semanas | Categorias, anunciantes, anúncios com programação de período, upload de fotos, controle de vagas com bloqueio no limite |
| 4. Portal público | 3 a 4 semanas | Home com cards, busca, listagem, página do anúncio, contato direto, QR code por mural, PWA e SEO básico |
| 5. Subpágina e agenda | 3 semanas | Galeria, qualificações, lista de serviços e lista de agendamento com confirmação pelo anunciante |
| 6. Financeiro | 3 semanas | Aluguéis e períodos, arranjos A, B e C, vencimentos, alertas e suspensão automática por inadimplência |
| 7. Piloto real | 4 semanas | Murais pilotos no ar, coleta de feedback, correções e métricas |
| 8. Evolução | contínuo | Avaliações, destaque pago, modo TV, bot de WhatsApp, relatórios automáticos, white-label e app nativo |
| 9. Expansão | após validação | Novos murais e nichos, material comercial |

**Total até o piloto:** cerca de 6 a 7 meses. O MVP vendável (fases 0 a 4) fica em 3 a 4 meses.

## 8. Decisões tomadas e riscos

**Decisões tomadas**

- **Inadimplência do administrador:** suspende o acesso dele ao painel, mas os anúncios e as lojas continuam no ar. A gestão passa ao master, que pode substituir o administrador.
- **Programação de período:** cada anúncio tem início e fim definidos. Vencido, sai da vitrine automaticamente.
- **Neutralidade:** por enquanto todos os anúncios têm o mesmo privilégio, com rodízio na ordem de exibição. Destaque pago fica para o futuro.
- **Administrador do bairro:** será usado pelo conhecimento local, com o master como retaguarda.

**Riscos que permanecem**

- **Oferta antes da demanda:** sem anunciantes cadastrados, o mural vazio não atrai visitantes. O catálogo precisa ser populado antes do lançamento.
- **Divulgação:** depende do QR code estar em lugar de grande circulação e da ação do administrador. No arranjo de venda direta, a divulgação passa a ser responsabilidade do master.
- **Qualidade do conteúdo:** fotos e descrições ruins enfraquecem o mural. É preciso um padrão mínimo.
- **Sigilo no nicho de contabilidade:** o escritório não pode expor dados de clientes sem consentimento, e indicar prestadores pode gerar questionamento de responsabilidade. O consentimento e as regras de uso precisam estar em contrato.
- **Cobrança na venda direta:** sem mediador, o master assume a inadimplência dos anunciantes. É preciso cobrança automática e bloqueio no vencimento.
- **Concorrência por nicho:** em condomínios, aplicativos de gestão já oferecem mural digital (seção 10).

## 9. Próximos passos recomendados

1. Prototipar o painel do administrador (cadastro de anúncio com programação de período, vagas usadas e controle de aluguel), que é onde está o negócio e que o protótipo atual não cobre.
2. Fazer o piloto manual em dois tipos de mural (fase 0).
3. Definir a tabela de preços das faixas de licença e dos planos por período.
4. Escolher o arranjo de cobrança do piloto (A, B ou ambos).
5. Decidir as três questões abertas da seção 13: seletor de mural, critério do selo verificado e exibição de avaliações.
6. Fechar o escopo do MVP: administrador cadastra e programa, público consulta e agenda, financeiro apenas como controle de status.

## 10. Panorama competitivo (pesquisa de 22/10/2026)

Já existem plataformas de serviços locais, mas nas buscas não apareceu nenhuma que combine catálogo curado por bairro, custo fixo e marca local; essa é a lacuna do projeto.

| Plataforma | Como funciona | Limitação para este projeto |
| --- | --- | --- |
| [GetNinjas](https://www.getninjas.com.br/termos-de-uso) | O profissional compra moedas para liberar o contato do cliente; os termos preveem preço variável por local e tipo de serviço, e há também um modelo de preço fechado com comissão. Em 2021 tinha mais de 3 milhões de profissionais cadastrados ([Forbes](https://forbes.com.br/forbes-tech/2021/08/inspirado-no-magalu-e-mercado-livre-getninjas-quer-oferecer-portfolio-completo-de-servicos-ao-brasil-inteiro/)) | Cobra por contato, e há reclamações no [Reclame Aqui](https://www.reclameaqui.com.br/getninjas/meus-pedidos-de-devolucao-de-moedas-nao-estao-sendo-atendidos_hvl-6LXizv_Y8Hm2/) sobre moedas perdidas quando o cliente não responde. Sem identidade de bairro |
| [Triider e Habitissimo](https://startups.com.br/noticias/triider-da-juntos-somos-mais-compra-a-operacao-da-habitissimo-no-brasil) | Orçamento por questionário e garantia própria, com cobertura de danos até R$ 5.000 após avaliação ([Canaltech](https://canaltech.com.br/apps/melhores-apps-contratar-vender-servicos/)) | Focam em reformas e manutenção e operavam em 17 cidades em 2021 |
| [Catalo](https://canaltech.com.br/apps/melhores-apps-contratar-vender-servicos/) | Busca por localização, avaliações e botão de WhatsApp no perfil | Cobertura depende da cidade e não há gestão por bairro |
| [Nextdoor](https://www.jb.com.br/ciencia-e-tecnologia/noticias/2011/10/26/amp/rede-social-para-conectar-vizinhos-e-lancada-nos-eua.html) | Rede social de vizinhos com verificação de endereço; recebe receita de publicidade local | Foco em conversa e comunidade, não em catálogo de serviços |
| Iniciativas locais ([Compre Local](https://www.abcdacomunicacao.com.br/stone-lanca-em-sao-paulo-o-compre-local-para-fortalecer-apoio-aos-pequenos-e-micros-empreendedores/), [Pernambuco](https://www.diariodepernambuco.com.br/noticia/economia/2020/09/amp/plataforma-gratuita-vai-aproximar-empreendedores-locais-de-compradores.html)) | Vitrines gratuitas lançadas em 2020 para pequenos negócios | Campanhas pontuais, sem modelo de licença recorrente |
| WhatsApp e redes sociais | Pesquisa do [Ipea](https://ipea.gov.br/cts/pt/central-de-conteudo/todas-as-publicacoes/publicacoes/552-plataformizacao-no-brasil) indica que 81% dos negócios pesquisados usam mensageria e 42% vendem por redes sociais, contra 22% em marketplaces | Concorrente real: é gratuito, mas o cliente só acha quem já conhece |

**Nicho condomínios:** aplicativos de gestão condominial já trazem mural digital de recados e avisos. O [Apepê](https://www.mobiletime.com.br/?p=712176) usa modelo SaaS cobrado do condomínio (R$ 7,99 por unidade, segundo o MobileTime), e o [Noknox](https://olhardigital.com.br/2022/03/04/pro/quintoandar-compra-aplicativo-noknox-e-deve-liderar-condominios/) foi comprado pelo QuintoAndar em 2022. O foco deles é gestão e comunicação, não um catálogo de prestadores com custo fixo por anúncio.

Limite da pesquisa: busca na web não prova que não exista concorrente idêntico. Antes de investir, vale conferir lojas de aplicativos e Google na sua região. Valores e modelos de cobrança podem ter mudado desde as fontes citadas.

## 11. Diferencial proposto: mural de confiança a custo fixo

O diferencial recomendado é o mural local curado por quem é conhecido no lugar, com aluguel fixo sem cobrança por contato, alcance nos pontos de grande circulação e subpágina com agenda.

1. **Custo fixo, sem pagar por lead.** O anunciante paga o aluguel do espaço e fala direto com o cliente pelo WhatsApp. É o oposto do modelo de moedas por contato.
2. **Presença onde as pessoas já circulam.** O mesmo produto serve bairro, escritório de contabilidade, mercadinho e condomínio, com QR code no ponto de visibilidade.
3. **Curadoria humana local.** O administrador conhece e verifica o prestador. Nenhuma plataforma nacional tem esse vínculo.
4. **Subpágina completa por anúncio.** Fotos, qualificações, serviços e lista de agendamento em um só lugar, sem o prestador precisar de site próprio.
5. **Avaliações só de visitantes verificados.** A verificação reduz avaliação falsa e dá peso à indicação.
6. **Prova de retorno.** Relatório mensal automático com visualizações, cliques e pedidos de agendamento, que justifica o aluguel e facilita a renovação.
7. **Automação por WhatsApp.** O visitante escreve "preciso de encanador" e recebe os prestadores do mural em rodízio. O sistema também envia lembretes de renovação e gera cartaz com QR code.

Hipótese a validar no piloto: os prestadores preferem aluguel fixo previsível a pagar por contato sem garantia de fechamento.

## 12. Requisitos desejáveis e decisões incorporadas

Os pontos de atenção e as decisões de negócio viram os requisitos abaixo. Os de prioridade Alta entram no MVP; os demais entram depois, em ordem de prioridade.

| Código | Origem | Requisito | Prioridade |
| --- | --- | --- | --- |
| RD01 | Oferta antes da demanda | Importação em lote de anunciantes por planilha e cadastro assistido. Checklist de lançamento com meta mínima de anunciantes por categoria antes de publicar o mural | Alta |
| RD02 | Divulgação | Gerador automático de cartaz com QR code e arte para Instagram e WhatsApp. Link compartilhável e botão de compartilhar em cada anúncio | Alta |
| RD03 | Decisão: inadimplência | Licença vencida suspende o acesso do administrador, mantém anúncios e lojas no ar e passa a gestão ao master, com carência configurável e avisos escalonados | Alta |
| RD04 | Decisão: substituição | O master pode substituir o administrador, com histórico de trocas e log de auditoria | Alta |
| RD05 | Decisão: programação | Programação de período do anúncio: início, fim, renovação, aviso de vencimento e saída automática da vitrine | Alta |
| RD06 | Decisão: cobrança | Pagador registrado em cada anúncio, aceitando os arranjos A (licença do administrador), B (venda direta) e C (híbrido com repasse) | Alta |
| RD07 | Segurança de dados | Consentimento do anunciante e termo de uso por mural. No nicho de contabilidade, nenhum dado de cliente exposto sem consentimento | Alta |
| RD08 | Qualidade do conteúdo | Validação mínima do anúncio (fotos, tamanho, descrição e contato válido), compressão automática e pontuação de qualidade do perfil | Média |
| RD09 | Decisão: subpágina | Subpágina do anúncio com galeria, qualificações e lista de serviços | Média |
| RD10 | Decisão: agendamento | Lista de agendamento na subpágina: pedido de horário, confirmação pelo anunciante e lembrete por WhatsApp | Média |
| RD11 | Novo escopo | Tipos de mural (bairro, escritório de contabilidade, comércio, condomínio) com categorias e textos pré-configurados | Média |
| RD12 | Concorrência (contatos inválidos) | Verificação periódica de WhatsApp e links, com aviso ao administrador quando o contato falhar | Média |
| RD13 | Diferencial (avaliações) | Avaliações apenas de visitantes verificados | Média |
| RD14 | Diferencial (retorno) | Relatório mensal automático de visualizações, cliques e pedidos por anunciante, por WhatsApp ou e-mail | Média |
| RD15 | Decisão: neutralidade | Todos os anúncios com o mesmo privilégio e rodízio na ordem de exibição. Destaque pago, sempre sinalizado como patrocinado, só em fase futura | Baixa |
| RD16 | Diferencial (automação) | Bot de WhatsApp que recebe o pedido do visitante e devolve prestadores em rodízio, além de lembretes automáticos de renovação | Baixa |
| RD17 | Diferencial (marca local) | White-label por mural, com logo, cores e domínio próprios, e regra opcional de repasse a associações | Baixa |

## 13. Análise do protótipo (Google Sites)

O protótipo valida a direção visual e a proposta de valor do lado público (seção 4C). A tabela mostra o que está alinhado, o que o planejamento ainda não cobria e o que precisa de ajuste.

| Elemento do protótipo | Avaliação | Ajuste no planejamento |
| --- | --- | --- |
| Mensagem "Apoie o comércio local... sem pagar taxas extras de intermediários" | Reforça o diferencial de custo fixo, mas o texto é específico de bairro | Textos por tipo de mural (RD11). Trocar por "sem comissão sobre o serviço", que continua verdadeiro nos arranjos A, B e C |
| Seletor de região (Jardim das Flores, São Paulo) | O planejamento previa abrir direto no mural do QR code, sem seletor público | Decisão aberta 1: o visitante pode trocar de mural? Recomendo abrir sempre no mural do QR code, com troca opcional para murais da mesma cidade |
| Busca com exemplos "manicure", "pedreiro", "vazamento", "bolo" | A busca precisa entender sinônimos: "vazamento" deve achar encanador | Tags e sinônimos por anúncio (campo novo no banco) |
| Chips de categoria e contador de resultados | Funcionam bem no desktop. O pedido original de cards quadrados por serviço é mais claro no celular | Chips no desktop e grade de cards quadrados de categoria na home do celular |
| Selo "MEI Verificado" | Alinha com o selo de confiança, mas hoje é só texto | Decisão aberta 2: definir o que é verificado. Recomendo CNPJ ativo como MEI consultado no cadastro mais confirmação do administrador. Sem validação real, o selo é risco de credibilidade |
| Selo "Verificado" ao lado do nome do portal | Sugere mural verificado | Selo de mural verificado pelo master, com administrador identificado |
| Nota e quantidade de avaliações (4.9, 38 avaliações) | Não estava no MVP. Mural novo começa com zero avaliações | Decisão aberta 3: exibir a nota só depois de um mínimo de avaliações (sugestão: 3) e liberar a avaliação após agendamento confirmado, o que evita avaliação falsa |
| Tag "Atende a Domicílio" | Atributo novo, não previsto | Campo de modo de atendimento no anúncio e filtro na busca |
| Endereço e botão de WhatsApp no card | Alinhado | Manter. Na página de detalhes, adicionar Instagram e rota no mapa |
| Botão "Ver Detalhes" | Corresponde à subpágina | Incluir o botão "Agendar" na subpágina |
| Fotos dos cards | São imagens genéricas, e a do pedreiro não mostra uma reforma | Usar só fotos reais do prestador, com padrão mínimo de qualidade (RD08) |

**Fora do protótipo:** o painel do administrador, a programação de período, o controle de vagas e o financeiro não aparecem, e são eles que sustentam a receita. O próximo protótipo deve cobrir essas telas.

### Requisitos novos a partir do protótipo

| Código | Requisito | Prioridade |
| --- | --- | --- |
| RD19 | Seletor de mural: o visitante abre o mural do QR code e pode trocar para murais da mesma cidade. A visibilidade entre murais é configurável | Média |
| RD20 | Verificação de MEI: consulta do CNPJ ativo no cadastro mais confirmação do administrador. O selo só aparece após os dois | Alta |
| RD21 | Busca por sinônimos: tags por anúncio e dicionário de sinônimos por categoria | Média |
| RD22 | Modo de atendimento (domicílio, no local ou ambos) e filtro na busca | Média |
| RD23 | Nota exibida apenas após o mínimo de avaliações, liberadas depois de agendamento confirmado. Complementa o RD13 | Média |
| RD24 | Home do celular com grade de cards quadrados de categoria | Média |
