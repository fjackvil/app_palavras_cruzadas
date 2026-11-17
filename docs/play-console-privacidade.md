# Privacidade na Play Console: o que preencher

Este guia é para a hora de publicar (fase 4). Ele vale para o app como está hoje (17/11/2026). Se o app mudar, por exemplo ao entrar o Premium ou os Grupos, revise as respostas.

**Por que as respostas são "não coletamos nada":** o app não pede **nenhuma** permissão. Não tem internet, câmera, galeria, localização, contatos nem microfone. Tudo o que o jogador cria fica no armazenamento privado do app, no próprio celular. Um teste automático (`app/test/telas/sobre_test.dart`) confere que o manifesto continua sem essas permissões.

Depois de compilar, dá para conferir as permissões finais com:

```bash
grep uses-permission app/build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml
```

Hoje a única permissão listada é uma interna do próprio Android (`DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`), que não dá acesso a nada.

## 1. Publicar a política de privacidade num endereço da internet

A Play Console pede o **link** da política. O texto é o mesmo que o app mostra:

- **Fonte:** `app/assets/textos/politica-de-privacidade.md`
- **Página pronta:** `docs/privacidade/index.html`. Para gerar de novo depois de editar o texto, rode na raiz do repositório:

  ```bash
  python3 tool/gerar_politica_html.py
  ```

O e-mail de contato da política é **vileladigit@gmail.com**. Use o mesmo como e-mail de contato do desenvolvedor na Play Console.

Onde publicar a página (escolha um):

| Opção | Custo | Observação |
| --- | --- | --- |
| GitHub Pages | Grátis em repositório público | Repositório privado só no plano pago do GitHub. Dá para criar um repositório público só com essa página. |
| Google Sites | Grátis | Colar o texto numa página. |
| Site próprio | Domínio + hospedagem | Fica mais profissional. |

## 2. Formulário "Segurança dos dados" (Data safety)

Em Play Console → Política do app → Segurança dos dados:

| Pergunta | Resposta |
| --- | --- |
| O app coleta ou compartilha algum dos tipos de dados exigidos? | **Não** |
| (Por isso as perguntas sobre criptografia e exclusão de dados não aparecem.) | — |

Dados que ficam **só no aparelho**, como nome do jogador, idade, foto e pontos, não contam como "coletados" pelas regras do Google, porque nunca saem do celular pelo app.

## 3. Outras declarações

| Seção da Play Console | Resposta |
| --- | --- |
| Política de privacidade | O link publicado no passo 1 |
| Anúncios | **Não**, o app não contém anúncios |
| Acesso ao app | Todo o app funciona sem login ou credencial especial |
| Público-alvo e conteúdo | Inclui faixas abaixo de 13 anos (o app é para a família). Isso aplica a **Política para Famílias** do Google, que o app já atende: sem anúncios, sem SDK de rastreio, sem coleta de dados. |
| Classificação de conteúdo (questionário IARC) | Sem violência, sexo, drogas ou linguagem imprópria. Interação entre usuários: **não**. Compartilha localização: **não**. Compras digitais: **não** por enquanto (mude para **sim** quando entrar o Premium). |
| App de notícias / saúde / finanças | Não |

## 4. Quando entrar o Premium (compras)

- O plugin `in_app_purchase` acrescenta a permissão `com.android.vending.BILLING`, que é a do Google Play para compras. Ela não dá acesso a dados do usuário.
- Na Segurança dos dados, compras feitas pelo Google Play Billing em geral continuam como "não coletado pelo app", porque o pagamento é do Google. Confira a orientação do Google na hora de publicar.
- Atualize a data e a seção "Compras" da política, se mudar algo.

Isto não é aconselhamento jurídico. A especificação recomenda uma revisão com advogado antes do lançamento.
