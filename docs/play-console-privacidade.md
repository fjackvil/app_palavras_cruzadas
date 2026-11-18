# Privacidade na Play Console: o que preencher

Este guia é para a hora de publicar (fase 4). Ele vale para o app como está hoje (17/11/2026). Se o app mudar, por exemplo ao entrar o Premium ou os Grupos, revise as respostas.

**Por que as respostas são "não coletamos nada":** o app não pede câmera, galeria, localização, contatos nem microfone. Tudo o que o jogador cria fica no armazenamento privado do app, no próprio celular. As únicas permissões vêm da biblioteca de compras do Google Play (`in_app_purchase`): `BILLING`, `INTERNET` e `ACCESS_NETWORK_STATE`. Elas servem só para a conversa com o Google Play sobre o Premium. O próprio app não tem nenhum código que envie dados. Um teste automático (`app/test/telas/sobre_test.dart`) confere que o manifesto do app não pede outras permissões.

Depois de compilar, dá para conferir as permissões finais com:

```bash
grep uses-permission app/build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml
```

O resultado esperado é: `com.android.vending.BILLING`, `android.permission.INTERNET`, `android.permission.ACCESS_NETWORK_STATE` e uma interna do Android (`DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`). Se aparecer outra, a política precisa ser revista.

## 1. Publicar a política de privacidade num endereço da internet

A Play Console pede o **link** da política. O texto é o mesmo que o app mostra:

- **Fonte:** `app/assets/textos/politica-de-privacidade.md`
- **Página pronta:** `docs/privacidade/index.html`. Para gerar de novo depois de editar o texto, rode na raiz do repositório:

  ```bash
  python3 tool/gerar_politica_html.py
  ```

**Publicada em:** https://fjackvil.github.io/palavras-cruzadas-privacidade/

Ela fica no repositório público `fjackvil/palavras-cruzadas-privacidade`, servido pelo GitHub Pages. No computador, o repositório fica ao lado deste projeto, em `git-fernando-pessoal/palavras-cruzadas-privacidade`. Para atualizar a página depois de mudar o texto:

```bash
python3 tool/gerar_politica_html.py
cp -r docs/privacidade/. ../palavras-cruzadas-privacidade/
cd ../palavras-cruzadas-privacidade && git add -A && git commit -m "Atualiza política e termos" && git push
```

O e-mail de contato da política é **vileladigit@gmail.com**. Use o mesmo como e-mail de contato do desenvolvedor na Play Console.

Onde publicar a página (escolha um):

| Opção | Custo | Observação |
| --- | --- | --- |
| GitHub Pages | Grátis em repositório público | Repositório privado só no plano pago do GitHub. Dá para criar um repositório público só com essa página. |
| Google Sites | Grátis | Colar o texto numa página. |
| Site próprio | Domínio + hospedagem | Fica mais profissional. |

**Termos de uso:** https://fjackvil.github.io/palavras-cruzadas-privacidade/termos/

O texto fica em `app/assets/textos/termos-de-uso.md`; o app mostra os termos na tela Sobre e privacidade, e o mesmo script gera a página.

## Página "Conteúdo do app" (para cada app)

Fica em Play Console → (o app) → Política e programas → Conteúdo do app. Cada item abaixo é uma declaração:

| Item | O que responder |
| --- | --- |
| Política de privacidade | https://fjackvil.github.io/palavras-cruzadas-privacidade/ |
| Acesso ao app | Todo o app funciona sem login nem credencial especial |
| Anúncios | Não, o app não contém anúncios |
| Classificação de conteúdo | Questionário IARC (ver a seção 3) |
| Público-alvo e conteúdo | Inclui menores de 13 anos (o app é para a família) → aplica a Política para Famílias |
| Segurança dos dados | Não coleta nem compartilha dados (ver a seção 2) |
| ID de publicidade | O app **não** usa o ID de publicidade |
| Apps de notícias, saúde, finanças, governo | Não |
| **Status de comerciante do app** | **Sim, é comerciante** (vende o Premium dentro do app), igual ao declarado na conta |
| **Termos de Serviço** | https://fjackvil.github.io/palavras-cruzadas-privacidade/termos/ |

## 2. Formulário "Segurança dos dados" (Data safety)

Em Play Console → Política do app → Segurança dos dados:

| Pergunta | Resposta |
| --- | --- |
| O app coleta ou compartilha algum dos tipos de dados exigidos? | **Não** |
| (Por isso as perguntas sobre criptografia e exclusão de dados não aparecem.) | — |

Dados que ficam **só no aparelho**, como nome do jogador, idade, foto e pontos, não contam como "coletados" pelas regras do Google, porque nunca saem do celular pelo app.

**Atenção: a biblioteca de compras do Google (`com.android.billingclient:billing`) envia telemetria.** Ela traz o módulo `datatransport` do Google, que manda ao Google dados técnicos de diagnóstico sobre as compras assim que o app abre. Isso foi visto no registro do emulador em 17/11/2026. Ela também traz o `play-services-location`, mas sem permissão de localização no app, então não lê localização. Nenhum dado dos jogadores vai junto. A política de privacidade já conta isso.

Antes de enviar o formulário, procure na ajuda da Play Console a orientação do Google sobre os dados que a **Play Billing Library** coleta (busque por "Play Billing Library" + "Segurança dos dados"). Então siga um destes caminhos:

- Se o Google disser que esses dados **não precisam ser declarados** pelo desenvolvedor (por serem do próprio Google Play), mantenha **"Não"** acima.
- Se disser que **precisam**, responda **"Sim, coleta"** e marque só:
  - **Informações e desempenho do app → Diagnóstico.**
  - Coletado: sim. Compartilhado: não.
  - Finalidade: funcionalidade do app.
  - Obrigatório: sim (vem junto com a compra).
  - Criptografado em trânsito: sim.
  - Os dados de pagamento ficam com o Google Play e não entram aqui.

Se mudar a biblioteca ou a versão dela, confira de novo com:

```bash
cd app/android && ./gradlew -q :app:dependencies --configuration releaseRuntimeClasspath | grep -iE "datatransport|location|analytics|firebase"
```

## 3. Outras declarações

| Seção da Play Console | Resposta |
| --- | --- |
| Política de privacidade | https://fjackvil.github.io/palavras-cruzadas-privacidade/ |
| Anúncios | **Não**, o app não contém anúncios |
| Acesso ao app | Todo o app funciona sem login ou credencial especial |
| Público-alvo e conteúdo | Inclui faixas abaixo de 13 anos (o app é para a família). Isso aplica a **Política para Famílias** do Google, que o app já atende: sem anúncios, sem SDK de rastreio, sem coleta de dados. |
| Classificação de conteúdo (questionário IARC) | Sem violência, sexo, drogas ou linguagem imprópria. Interação entre usuários: **não**. Compartilha localização: **não**. Compras digitais: **sim** (Premium, compra única). |
| App de notícias / saúde / finanças | Não |

## 4. Premium (compra única)

- **Produto a criar na Play Console:** em Monetizar → Produtos → Produtos no app, crie um produto **não consumível** com o ID **`premium`**, nome "Premium" e preço **R$ 9,90**. O ID precisa ser exatamente esse, porque é o que o app procura (`app/lib/dominio/plano.dart`).
- **Teste da compra:** só funciona com o app instalado pela Play Store, numa faixa de teste (teste interno ou fechado). Cadastre a sua conta Google em Configurações → Teste de licença: assim a compra é de teste e não cobra de verdade.
- **Segurança dos dados:** o pagamento é processado pelo Google Play. O app não recebe dados de pagamento, então a resposta continua "não coletamos". Confira a orientação do Google na hora de publicar.

Isto não é aconselhamento jurídico. A especificação recomenda uma revisão com advogado antes do lançamento.
