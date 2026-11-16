# Especificação — App de Palavras Cruzadas para Android

15/11/2026 · Fernando Jackson Vilela

## Visão geral

Um app Android de palavras cruzadas e caça-palavras em português, para todas as idades, com níveis ajustados à idade, 65 temas, pontuação, cronômetro, ranking entre os jogadores do aparelho e modelo freemium (grátis com limites + assinatura ou compra única).

**Privacidade em primeiro lugar:** para jogar não há cadastro nem login, e tudo fica só no celular. A conta Google é opcional e serve apenas para quem quiser participar de grupos com outras pessoas.

O ponto de partida é um jogador real: uma criança de 8 anos. Por isso o nível Leve precisa ser realmente acessível (grades pequenas, palavras curtas, dicas simples ou com imagem), sem deixar de ser desafiador para adultos nos níveis mais altos.

**Objetivos do produto**

- Divertir e ensinar: vocabulário, ortografia e conhecimentos gerais.
- Servir a família inteira em um só aparelho (vários perfis).
- Gerar receita pela Google Play com um plano gratuito atraente e um plano premium claro.
- Ter conteúdo praticamente infinito, sem repetir desafios.

**Fora do escopo da primeira versão:** iOS, modo multiplayer em tempo real, versão web, ranking global e sincronização entre aparelhos.

## Apps de referência

O mercado em português tem bons apps de cruzadas para adultos, mas quase nenhum combina níveis por idade, escolha de tema e perfil infantil — esse é o espaço do nosso app.

Não tive acesso à internet nesta análise: a tabela vem do meu conhecimento até meados de 2026 e deve ser conferida na Play Store antes de decidir.

| App | O que faz bem | O que falta (oportunidade) |
| --- | --- | --- |
| Coquetel (Ediouro) | Marca forte no Brasil, cruzadas diretas clássicas, vários níveis | Pouca escolha de tema, nada pensado para crianças |
| Palavras Cruzadas (Fanatee e similares) | Visual limpo, desafio diário, monetização com anúncios | Sem perfis familiares, temas genéricos |
| CodyCross | Temas em "mundos", progressão viciante, muito sucesso global | Formato próprio (não é grade clássica), sem nível por idade |
| Crossword Explorer / Daily Crossword | Desafio diário, estatísticas, sequência de dias jogados | Em inglês, foco adulto |
| NYT Games (Mini Crossword) | Grade 5×5 rápida, ranking entre amigos, assinatura | Inglês, sem temas escolhidos pelo usuário |
| Word Search / Caça-palavras infantis | Ilustrações, linguagem simples | Não são cruzadas; pouco desafio para adultos |

**Boas ideias para copiar**

- Desafio diário igual para todos (cria hábito e permite comparar com amigos).
- Sequência de dias jogados ("streak") e conquistas.
- Botão de dica que revela uma letra ou palavra, com custo em pontos.
- Mini grade rápida (5×5) para quem tem pouco tempo.

## Cadastro, perfis e níveis

Para jogar não há conta nem login: os jogadores são criados e guardados só no celular. Um mesmo aparelho pode ter até 5 perfis, e a compra do Premium vale para todos eles. A conta Google só é pedida para quem quiser participar de grupos (seção "Grupos").

**Fluxo de primeiro uso**

1. Abre o app e toca em "Novo jogador".
2. Escolhe um nome ou apelido, a idade e um avatar. Esses dados ficam só no celular e nunca são enviados.
3. O app sugere o nível pela idade; a pessoa pode subir ou descer depois.
4. Para trocar de jogador, toca no avatar no topo da tela.

**Níveis por idade (sugestão inicial)**

| Nível | Idade sugerida | Grade | Tamanho das palavras | Dicas |
| --- | --- | --- | --- | --- |
| Leve | 6–9 anos | 5×5 a 7×7 | 3–6 letras | Frases simples, imagem opcional, primeira letra visível |
| Médio | 10–13 anos | 9×9 a 11×11 | 4–8 letras | Definições diretas |
| Difícil | 14+ anos | 13×13 | até 10 letras | Definições e sinônimos |
| Super difícil | adultos experientes | 15×15 | até 13 letras | Dicas indiretas, trocadilhos, palavras raras |

A idade só sugere o nível; quem decide é a pessoa. Se alguém completa 3 desafios seguidos rápido e sem dicas, o app oferece subir de nível.

## Funcionalidades do jogo

Cada desafio registra pontos, tempo, dicas usadas e estado (em andamento, desistido, concluído), e tudo é salvo automaticamente a cada letra digitada.

**Tela de jogo**

- Grade tocável; ao tocar uma casa, destaca a palavra e mostra a dica.
- Teclado próprio do app (letras grandes no nível Leve; acentos tratados automaticamente: "AÇÃO" vira "ACAO" na grade).
- Cronômetro visível (pode ser ocultado no nível Leve para não estressar crianças).
- Botões: dica, verificar palavra, pausar, desistir.

**Pontuação (proposta)**

- 10 pontos por letra correta, multiplicados pelo nível: Leve ×1, Médio ×1,5, Difícil ×2, Super difícil ×3.
- Bônus de tempo: quanto mais rápido em relação ao tempo-alvo do desafio, maior o bônus (até +50%).
- Dica de letra custa 15 pontos; dica de palavra inteira custa 50.
- Concluir sem nenhuma dica dá bônus de +20%.

**Desistir e voltar depois**

- "Desistir" não apaga nada: o desafio vai para a aba **Pendentes** com o progresso e o tempo já gasto.
- O jogador escolhe outro desafio na hora.
- Ao retomar, o cronômetro continua de onde parou.
- Opção "Ver resposta" encerra o desafio sem pontos (só depois de desistir).

**Outros recursos**

- Histórico de desafios concluídos com nota e tempo.
- Estatísticas por perfil: total de pontos, média de tempo, temas favoritos.
- Desafio diário e sequência de dias jogados.
- Funciona offline com os desafios já baixados; o progresso fica salvo só no celular.

## Modo caça-palavras

O segundo modo de jogo usa os mesmos temas e a mesma biblioteca de palavras: o jogador acha as palavras escondidas numa grade de letras, arrastando o dedo sobre elas. É mais fácil que as cruzadas, então é uma boa porta de entrada para crianças.

| Nível | Grade | Palavras | Lista |
| --- | --- | --- | --- |
| Leve | 8×8 | 6 | Palavras visíveis |
| Médio | 10×10 | 8 | Palavras visíveis |
| Difícil | 12×12 | 10 | Palavras visíveis |
| Super difícil | 12×12 | 12 | Só as dicas, sem as palavras |

- Em todos os níveis as palavras podem estar em qualquer uma das 8 direções: horizontal, vertical e diagonal, para a frente e de trás para a frente (decidido em 16/11/2026).

- Ao achar uma palavra, ela ganha uma cor e é riscada na lista.
- Pontuação, cronômetro, dica (revela a primeira letra da palavra, custando pontos), desistir e pendentes funcionam igual às cruzadas.
- Acentos removidos na grade, como nas cruzadas ("AÇÃO" vira "ACAO").
- A grade é montada no próprio celular e existe um desafio diário para cada modo.
- No plano grátis, o limite de desafios por dia vale somando os dois modos.
- Grade de no máximo 12×12, para as letras não ficarem pequenas demais na tela do celular.

## Temas e assuntos

Proponho 12 categorias com 65 temas no lançamento; o usuário escolhe um ou vários temas, ou "Misturado". Cada tema tem uma marca de faixa etária, para que perfis infantis só vejam temas adequados.

As palavras abaixo são exemplos; o banco completo (meta: 300+ palavras por tema, cerca de 15 mil no total) é montado na fase de conteúdo (seção "Geração de conteúdo").

| Categoria | Temas | Exemplos de palavras | Infantil? |
| --- | --- | --- | --- |
| Mundo | Países, Capitais, Bandeiras, Estados do Brasil, Cidades, Continentes e oceanos, Pontos turísticos | BRASIL, LISBOA, AMAZONAS, OCEANIA, COLISEU | Sim |
| Natureza | Animais, Animais marinhos, Insetos, Plantas e flores, Frutas, Clima, Planetas e espaço | ELEFANTE, POLVO, JOANINHA, GIRASSOL, SATURNO | Sim |
| Comida | Alimentos, Pratos típicos brasileiros, Doces, Bebidas, Culinária do mundo, Temperos | FEIJOADA, BRIGADEIRO, ACARAJE, SUSHI, CANELA | Sim |
| Cinema e TV | Filmes, Séries, Desenhos animados, Novelas, Atores e diretores, Super-heróis | NOVELA, ROTEIRO, ANIMACAO, ESTREIA, VILAO | Parcial |
| Música | Gêneros musicais, Instrumentos, Música brasileira, Cantores e bandas, Termos musicais | SAMBA, VIOLAO, BOSSANOVA, PANDEIRO, REFRAO | Sim |
| História | História do Brasil, História mundial, Antiguidade, Personagens históricos, Invenções | IMPERIO, FARAO, ABOLICAO, IMPRENSA, CABRAL | Parcial |
| Ciência | Corpo humano, Química, Física, Matemática, Tecnologia, Dinossauros | ESQUELETO, ATOMO, GRAVIDADE, TRIANGULO, TIRANOSSAURO | Sim |
| Esportes | Futebol, Olimpíadas, Esportes em geral, Times brasileiros, Atletas famosos | GOLEIRO, MARATONA, JUDO, ESCANTEIO, PODIO | Sim |
| Cultura | Literatura brasileira, Folclore, Festas populares, Artes e pintores, Mitologia | SACI, CURUPIRA, CARNAVAL, QUADRILHA, ZEUS | Sim |
| Dia a dia | Profissões, Objetos da casa, Escola, Cores e formas, Meios de transporte, Roupas | DENTISTA, GELADEIRA, MOCHILA, LOSANGO, BICICLETA | Sim |
| Língua portuguesa | Sinônimos, Antônimos, Expressões populares, Palavras difíceis | ALEGRE, OUSADO, EFEMERO, PROLIXO | Não (níveis altos) |
| Atualidades | Notícias do mês, Tecnologia e internet, Meio ambiente | RECICLAGEM, APLICATIVO, SUSTENTAVEL | Parcial |

**Regras do banco de palavras**

- Cada palavra tem: tema, dificuldade (1–4), dica por nível e marca "adequada para crianças".
- "Atualidades" é atualizada todo mês (bom motivo para a assinatura).
- Nomes de filmes, séries e marcas: usar termos genéricos ou nomes de pessoas e títulos apenas como resposta de dica, nunca imagens ou logotipos, para evitar problemas de direitos autorais.

## Ranking local e compartilhamento

Não há ranking global: as pontuações ficam só no celular, e a competição acontece entre os jogadores do mesmo aparelho ou por compartilhamento feito pelo próprio usuário.

- **Placar da família:** ranking entre os perfis do aparelho, por semana, por nível e por tema.
- **Recordes pessoais:** melhor tempo e maior pontuação em cada desafio e tema.
- **Desafio diário:** a mesma grade para todos no dia (vem junto com o conteúdo baixado), então dá para comparar com amigos fora do app.
- **Compartilhar resultado:** um botão gera um texto ou imagem ("Cruzada do dia: 850 pontos em 4min12s") e abre o compartilhamento do Android (WhatsApp etc.). Quem decide enviar é o usuário; nada passa pelo nosso servidor.
- **Conquistas:** medalhas locais, como 7 dias seguidos jogando ou 10 desafios sem dica.

## Grupos (conta opcional)

Qualquer pessoa pode criar um grupo (família, amigos, colegas) e convidar outras pessoas; só quem usa grupos precisa entrar com a conta Google.

**Como funciona o convite**

1. Na aba Grupos, a pessoa entra com a conta Google, escolhe um apelido e cria o grupo (por exemplo, "Família Vilela").
2. Convida pelo e-mail do convidado ou manda um link pelo WhatsApp.
3. Quando o convidado entra no app com a conta Google daquele e-mail, ou abre o link, aparece a mensagem: "Fulano convidou você para o grupo Família Vilela. Participar?"
4. Aceitando, ele passa a aparecer no placar do grupo.

**Regras**

- O placar do grupo é semanal e separado por modo (cruzadas e caça-palavras), mostrando só apelidos.
- Só os membros veem o grupo; não existe ranking aberto para todos.
- Quem criou o grupo pode remover membros, e qualquer membro pode sair.
- Um perfil de criança no celular dos pais pode entrar no grupo da família, só com apelido e com a autorização do responsável, que é o dono da conta.
- Sair de todos os grupos e excluir a conta apaga esses dados do servidor.

## Monetização e compras na Google Play

Continua freemium, cobrado pelo Google Play Billing, mas sem login no app: a compra fica ligada à conta Google da Play Store do aparelho, e o app só pergunta ao Google se aquela conta já comprou.

**Como funciona a compra sem servidor**

- Todo conteúdo digital vendido dentro do app precisa usar o Google Play Billing. O Google cuida do pagamento, de reembolsos e de impostos.
- Ao abrir, o app consulta as compras da conta Google do aparelho. Se houver Premium, libera tudo para todos os perfis daquele celular.
- Trocou de celular? Basta usar a mesma conta Google na Play Store: o Premium volta sozinho, sem cadastro.
- O app confere a assinatura digital que o Google coloca em cada compra, usando a chave pública do app. Sem servidor, um app pirateado ainda consegue burlar isso; é um risco aceitável no começo.
- Se a criança usa uma conta Google infantil (Family Link), a compra precisa da aprovação dos pais, feita pelo próprio Google.
- Sem RevenueCat: ele exigiria enviar um identificador do usuário para um serviço externo.

**Custos e taxas (valores aproximados, confirmar)**

- Conta de desenvolvedor Google Play: taxa única de US$ 25.
- Comissão do Google: 15% sobre assinaturas e sobre o primeiro US$ 1 milhão por ano; 30% acima disso em compras avulsas.
- Contas pessoais novas precisam de um teste fechado com cerca de 12 testadores por 14 dias antes de publicar.

**Grátis × Premium (proposta)**

| Recurso | Grátis | Premium |
| --- | --- | --- |
| Níveis | Leve e Médio | Todos, incluindo Difícil e Super difícil |
| Temas | 10 temas básicos | Todos os 65 e os novos de cada mês |
| Desafios por dia | 3 | Ilimitados |
| Desafio diário e ranking | Sim | Sim |
| Perfis | 1 | Até 5 |
| Dicas | 3 por dia | Ilimitadas |
| Anúncios | Nenhum (os limites substituem os anúncios) | Sem anúncios |
| Pendentes guardados | Até 3 | Ilimitados |

**Preços sugeridos (testar):** R$ 9,90/mês, R$ 59,90/ano, R$ 99,90 vitalício. Oferecer 7 dias grátis na assinatura anual.

## Tecnologia recomendada

Continua **Flutter** no app. No beta, as palavras vêm de **arquivos JSON dentro do app**, sem servidor; o **Supabase** só entra depois, para servir o conteúdo. Os dados dos jogadores ficam sempre num banco local no celular.

| Camada | Escolha | Por quê |
| --- | --- | --- |
| App | Flutter (linguagem Dart) | Android hoje e iOS no futuro com o mesmo código |
| Dados dos jogadores | Banco local Drift (SQLite) | Tudo fica no celular e funciona offline; entra no backup automático do Android |
| Conteúdo do jogo | Beta: arquivos JSON em assets/palavras/. Depois: Supabase, leitura pública sem login | Beta: zero servidor e zero custo. Depois: atualizar temas sem publicar nova versão do app |
| Compras | Plugin oficial `in_app_purchase` (Google Play Billing) | Sem login; confere a assinatura do Google no aparelho |
| Gerador de grades | Beta: dentro do app, em Dart. Depois: script rodando fora do app | Grades pequenas saem em milissegundos; o desafio diário usa a data como semente |
| Compartilhar resultado | `share_plus` (compartilhamento do Android) | O usuário envia; nada passa pelo servidor |
| Travamentos | Android vitals da Play Console | Sem SDK de rastreio no app |

**Grupos (depois do beta):** login com Google pelo Supabase Auth, tabelas de grupos no Supabase e a mensagem de convite exibida dentro do app ao entrar. O resto do jogo continua funcionando sem conta.

**Arquitetura (sem conta, os dados ficam só no celular)**

```text
┌─────────────── Celular do jogador ───────────────┐
│  App (Flutter)  ⇄  Banco local                   │  ⇄  Google Play
│  jogo, perfis       perfis, partidas, recordes   │     (cobrança e assinaturas)
└──────────────────────────────────────────────────┘
          ↑ conteúdo e grupos (opcional)
     Supabase  ←  Gerador de grades
     conteúdo e grupos de quem tem conta
```

Sem conta, perfis, partidas e recordes ficam só no banco local. Quem cria conta para grupos envia ao Supabase apenas e-mail, apelido e o placar do grupo.

No beta, o Supabase e o gerador externo ficam de fora: as palavras vêm num JSON dentro do app, e as grades são montadas no próprio celular.

**Alternativas consideradas**

- **Kotlin + Jetpack Compose (nativo):** ótimo desempenho, mas só Android; se um dia quiser iPhone, refaz tudo.
- **React Native:** também multiplataforma; Flutter leva vantagem em desenho de grade e teclado personalizados.

Flutter e Android Studio rodam bem no Linux, e o projeto pode ficar no GitHub e ser desenvolvido com o Claude Code em qualquer uma das suas máquinas.

## Modelo de dados

Os dados ficam em lugares separados: o conteúdo do jogo (JSON no beta, Supabase depois), os grupos no Supabase só para quem cria conta, e todo o resto sobre os jogadores no banco local do celular.

**No beta:** em vez das tabelas do Supabase, o conteúdo vai em um arquivo JSON por tema, em `assets/palavras/` (por exemplo, `animais.json`), com os mesmos campos. Assim, a migração para o Supabase depois é direta.

```json
{
  "tema": "Animais",
  "categoria": "Natureza",
  "infantil": true,
  "premium": false,
  "palavras": [
    {
      "palavra": "ELEFANTE",
      "dificuldade": 1,
      "dicas": {
        "leve": "Animal grande com tromba",
        "media": "Maior mamífero terrestre",
        "dificil": "Paquiderme africano ou asiático"
      }
    }
  ]
}
```

**No Supabase (público, somente leitura)**

| Tabela | Campos principais | Para quê |
| --- | --- | --- |
| temas | id, categoria, nome, infantil, premium, ativo | Lista de temas e o que é pago |
| palavras | id, palavra, palavra_grade (sem acento), tema_id, dificuldade 1–4, dica_leve, dica_media, dica_dificil, infantil | Biblioteca de palavras e dicas |
| desafios | id, nivel, tema_ids, grade (JSON), tempo_alvo, diario (data ou vazio), premium | Grades prontas para baixar |
| pacotes | id, versao, criado_em | Avisa o app quando há conteúdo novo |

Só você escreve nessas tabelas. O app lê com a chave pública, e as regras de segurança (RLS) permitem apenas leitura.

**No Supabase: grupos (só para quem cria conta)**

| Tabela | Campos principais | Para quê |
| --- | --- | --- |
| contas | id (do login), email, apelido, aceite_termos_em | Quem usa grupos |
| grupos | id, nome, dono_id, codigo_convite, criado_em | Grupos criados |
| membros | grupo_id, conta_id, apelido_perfil, papel (dono/membro), entrou_em | Quem participa, incluindo perfis de crianças autorizados |
| convites | id, grupo_id, email_convidado, enviado_por, estado (pendente/aceito/recusado), criado_em | Mensagem de convite ao entrar no app |
| placar_semanal | grupo_id, membro_id, semana, modo, pontos, melhor_tempo | Placar do grupo |

As regras de segurança (RLS) deixam cada pessoa ler só os grupos de que participa e só os convites enviados para o próprio e-mail. Guardar o placar somado por semana, e não cada partida, mantém o banco pequeno: cerca de 1 a 2 KB por usuário.

**No celular (banco local)**

| Tabela | Campos principais | Para quê |
| --- | --- | --- |
| perfis | id, nome, ano_nascimento, avatar, nivel_atual | Jogadores do aparelho, até 5 |
| partidas | id, perfil_id, modo (cruzadas/caça-palavras), desafio_id, estado (andamento/desistido/concluido), respostas, tempo_gasto_seg, dicas_usadas, pontos, atualizado_em | Progresso, pendentes e histórico |
| recordes | perfil_id, desafio ou tema, melhor_pontuacao, melhor_tempo | Placar da família e recordes |
| conquistas | perfil_id, conquista, data | Medalhas |
| desafios_baixados | cópia das grades e palavras já baixadas | Jogar offline |

O Premium não fica gravado como verdade no celular: o app pergunta ao Google a cada abertura e guarda só uma cópia para funcionar offline.

## Geração de conteúdo

Recomendo gerar as grades automaticamente, por um programa, a partir do banco de palavras revisado, em vez de criar uma por uma ou gerar tudo com IA na hora do jogo.

**Como montar o banco de palavras**

1. Usar IA (por exemplo, Claude) para propor palavras e dicas por tema e por nível, em lotes.
2. Revisão humana: conferir ortografia, se a dica está certa e se é adequada para crianças. Esse é o passo mais importante para a qualidade.
3. Salvar no JSON do tema (beta) ou importar no Supabase (tabela `palavras`).
4. Cruzar com uma lista de palavras válidas do português (por exemplo, dicionários abertos como o VERO/LibreOffice) para evitar erros.

**Como gerar as grades**

- Um script gerador (algoritmo de encaixe com retrocesso, "backtracking") monta grades do tamanho do nível usando palavras do tema escolhido.
- Beta: o app monta as grades na hora, no próprio celular. Depois: gerar milhares de grades com antecedência e guardar na tabela `desafios`; o app baixa lotes.
- O desafio diário usa a data como semente do gerador, então é igual para todos sem precisar de servidor.
- Estilo da grade: americano (grade com casas pretas, dicas numeradas em lista), mais fácil de ler no celular que o formato "direto" das revistas.

**Por que não gerar com IA na hora:** custo por partida, demora de alguns segundos e risco de dica errada sem revisão.

## Privacidade, crianças e regras da Play Store

Quem joga sem conta não tem nenhum dado coletado. Quem cria conta para grupos tem guardados só e-mail, apelido, grupos e o placar semanal; por isso a conta é de um adulto, e crianças entram nos grupos pelo perfil no celular dos pais, com a autorização deles.

- **Conta para grupos:** termos de uso e política de privacidade aceitos no cadastro, com uma caixa de confirmação; opção de excluir a conta dentro do app e por um link na web, apagando tudo do servidor.
- **O que fica no celular:** nomes dos perfis, idades, partidas, pendentes, pontos e recordes. Nada disso é enviado para nós.
- **O que vem da internet:** só o conteúdo do jogo (temas, palavras e grades), que no beta já vem dentro do app, sem nenhuma conexão. Depois, será baixado do Supabase sem login, e o servidor só recebe o pedido de download, sem identificar quem joga.
- **Sem anúncios e sem SDKs de rastreio** (AdMob, Firebase Analytics, Crashlytics), porque todos coletam identificadores do aparelho. Travamentos podem ser acompanhados pelo Android vitals da Play Console.
- **Ainda é obrigatório:** política de privacidade publicada (explicando o que é guardado só para quem cria conta), formulário de Segurança de Dados declarando e-mail, apelido e placar dos grupos e as regras de Famílias da Play, já que crianças fazem parte do público.
- **Backup e troca de aparelho:** o backup automático do Android fica ligado. Perfis, partidas e recordes vão para o Google Drive do próprio usuário, fora do nosso alcance, e voltam ao reinstalar o app ou ao trocar de celular com a mesma conta Google. Não há sincronização em tempo real entre dois aparelhos.

Recomendo uma revisão com advogado antes do lançamento; isto não é aconselhamento jurídico.

## Roadmap, riscos e perguntas em aberto

Sugiro lançar em 4 fases, começando por uma versão que seu filho já possa jogar, e só depois ligar os pagamentos.

**Fases (estimativa para uma pessoa com ajuda do Claude Code)**

1. **Protótipo jogável (3–4 semanas):** grade, teclado, dicas, pontos, tempo, 5 temas, níveis Leve e Médio, perfis locais. Seu filho testa.
2. **Conteúdo (4 semanas):** biblioteca de palavras revisada nos 65 temas, gerador de grades, arquivos JSON por tema, 4 níveis, desafio diário.
3. **Caça-palavras, família e recordes (3–4 semanas):** modo caça-palavras, placar da família, recordes, conquistas e compartilhar resultado.
4. **Monetização e publicação (3 semanas):** Google Play Billing, plano grátis × Premium, política de privacidade, teste fechado com 12 testadores por 14 dias, lançamento.

**Depois do beta**

- **Grupos (3–4 semanas):** login opcional com Google, criar grupo, convidar por e-mail ou link, mensagem de convite ao entrar, placar semanal, termos de uso e exclusão de conta.
- **Conteúdo no Supabase:** levar temas e palavras para o servidor, para adicionar conteúdo sem publicar uma nova versão do app.

**Principais riscos**

- Qualidade das dicas: dica errada derruba a avaliação na loja. Mitigação: revisão humana.
- Regras de Famílias da Play: o app passa por análise; sem anúncios e sem SDKs de rastreio, o risco cai muito.
- Pirataria do Premium sem servidor: aceitar no começo; se virar problema, criar uma validação mínima no servidor que não guarde dados pessoais.
- Plano gratuito do Supabase: pausa o projeto após 7 dias sem acesso e não faz backup. Mitigação: assinar o Pro (cerca de US$ 25/mês) quando o app começar a vender.
- Concorrência forte (Coquetel, CodyCross): o diferencial precisa ficar claro na loja — dois modos de jogo, temas à escolha, níveis por idade, grupos e privacidade.

**Perguntas para você decidir**

- [x] Nome do app: **Palavras Cruzadas** (decidido em 16/11/2026, no lugar de "Cruza Letra", porque é o nome que as pessoas procuram na loja; identificador `com.vileladigit.palavrascruzadas`)
- [ ] Confirmar: conta de grupos só para maiores de 18 anos?
- [ ] Confirmar: sem anúncios no plano grátis, para não coletar dados?
- [ ] Grupos só no Premium, ou também no plano grátis?
- [ ] Assinatura, compra única, ou as duas?
- [ ] Mostrar o botão de compartilhar resultado também em perfis de crianças?
- [ ] Só português, ou planejar outros idiomas no futuro?
- [ ] Algum tema deve ficar de fora (por exemplo, política em "Atualidades")?
- [ ] Grade estilo americano (recomendado) ou estilo "direto" de revista brasileira?

## Repositório no GitHub

O projeto fica num repositório privado no GitHub, com esta especificação dentro, para trabalhar de qualquer computador e com o Claude Code lendo as decisões direto do repositório.

**Estrutura de pastas**

```text
palavras-cruzadas/
├── CLAUDE.md              instruções para o Claude Code
├── README.md
├── .gitignore
├── docs/
│   ├── especificacao.md   este documento
│   └── marca/             icone-vilela.svg e icone-vilela.png
├── app/                   projeto Flutter
│   └── assets/palavras/   um JSON por tema
├── tools/gerador/         gerador de grades (depois do beta)
└── supabase/              tabelas e regras dos grupos (depois do beta)
```

**Passo a passo no desktop**

1. No GitHub, crie um repositório privado. Nome provisório: `palavras-cruzadas` (dá para renomear depois).
2. Clone, copie os arquivos deste pacote e envie:

```bash
git clone git@github.com:SEU-USUARIO/palavras-cruzadas.git
cd palavras-cruzadas
# copie para cá: CLAUDE.md, README.md, .gitignore e a pasta docs/
git add .
git commit -m "Especificação inicial e ícone"
git push
```

3. Crie o projeto Flutter dentro de `app/` e envie de novo:

```bash
flutter create --org com.vileladigit --platforms android app
git add .
git commit -m "Projeto Flutter inicial"
git push
```

4. Abra o Claude Code na pasta do repositório e peça a fase 1 do roadmap. Ele lê o `CLAUDE.md` e, por ele, esta especificação.

**Cuidados**

- Nunca subir para o GitHub: a chave de assinatura do app (`.jks`, `key.properties`), chaves secretas do Supabase e arquivos `.env`. Eles já estão no `.gitignore` do pacote.
- Em mais de uma máquina: `git pull` ao começar e `git push` ao terminar.
- O identificador do app (`com.vileladigit.<nome>`) não pode mudar depois de publicado na Play Store: defina o nome do app antes de publicar.
