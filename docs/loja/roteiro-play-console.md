# Roteiro na Play Console: do app criado ao teste fechado

Faça na ordem. Os nomes dos menus podem mudar um pouco; se não achar, use a busca da Play Console. As respostas das declarações estão em `docs/play-console-privacidade.md`; os textos e imagens da loja estão nesta pasta (`docs/loja/`).

## 1. Criar o app

Play Console → **Criar app**:

| Campo | O que pôr |
| --- | --- |
| Nome do app | Palavras Cruzadas |
| Idioma padrão | Português (Brasil) – pt-BR |
| App ou jogo | **Jogo** |
| Sem custo financeiro ou pago | **Sem custo financeiro** (o Premium é compra dentro do app; um app gratuito não pode virar pago depois) |
| Declarações | Marque as duas (políticas do programa e leis de exportação dos EUA) |

## 2. Painel → "Configurar o app" (Conteúdo do app)

Responda cada item com a tabela de `docs/play-console-privacidade.md`:

1. Política de privacidade: https://fjackvil.github.io/palavras-cruzadas-privacidade/
2. Acesso ao app: tudo funciona sem login.
3. Anúncios: não.
4. Classificação de conteúdo: questionário IARC (categoria **Jogo**, sem violência etc.; compras digitais: sim).
5. Público-alvo: **todas as faixas**, inclusive "5 anos ou menos". Como inclui crianças, a Play pede mais detalhes da Política para Famílias: sem anúncios, sem dados coletados.
6. Segurança dos dados: siga a seção 2 do documento (atenção à parte da biblioteca de compras).
7. ID de publicidade: não usa.
8. Apps governamentais, financeiros, de saúde, notícias: não.
9. Status de comerciante e Termos de Serviço: sim, comerciante; termos em https://fjackvil.github.io/palavras-cruzadas-privacidade/termos/

## 3. Página principal da loja

Presença na loja → **Página principal da loja**: use `docs/loja/textos-da-loja.md` (nome, descrição curta, descrição completa) e as imagens:

- Ícone: `docs/loja/icone-512.png`
- Gráfico de recursos: `docs/loja/destaque-1024x500.png`
- Capturas de tela do celular: `docs/loja/telas/` (ainda a fazer)

E em **Configurações da loja**: categoria **Palavras**, e-mail vileladigit@gmail.com.

## 4. Países

Teste e lançamento → **Países/regiões**: só **Brasil**.

## 5. Teste fechado

Teste e lançamento → Testes → **Teste fechado** → criar faixa (pode usar a "Alpha" que já vem):

1. **Testadores:** crie uma lista de e-mails (as contas Google dos testadores; precisam ser pelo menos 12) ou use um Grupo do Google.
2. **Criar versão** → aceite a **Assinatura de apps do Google Play** (o Google guarda a chave da loja; a sua chave de upload continua só no seu computador).
3. **Enviar o pacote:** gere antes com `tool/pacote.sh loja` e envie `app/build/app/outputs/bundle/release/app-release.aab`. Guarde a pasta `app/simbolos/<versão>-loja/` no Drive.
4. Nome da versão: `1.0.0 (1)`. Notas da versão (pt-BR): "Primeira versão de teste. Obrigado por ajudar!"
5. Revisar e **enviar para análise**. A primeira análise do Google costuma levar de alguns dias a uma semana.
6. Depois de aprovado, copie o **link de participação** do teste e mande para os testadores. Cada um abre o link no celular, aceita participar e instala pela Play Store.

**Regra do Google para contas pessoais novas:** pelo menos **12 testadores** com o app instalado **durante 14 dias seguidos** antes de pedir o acesso à produção. Eles não precisam jogar todo dia, mas não podem desinstalar nem sair do teste.

## 6. O produto Premium

Só aparece depois que um pacote com a biblioteca de compras foi enviado (passo 5).

Monetizar → Produtos → **Produtos no app** → Criar produto:

| Campo | O que pôr |
| --- | --- |
| ID do produto | `premium` (exatamente assim) |
| Nome | Premium |
| Descrição | Libera tudo: todos os níveis e temas, desafios e dicas sem limite e até 5 jogadores. |
| Preço | R$ 9,90 |

Ative o produto. Para testar a compra sem pagar: Configurações → **Teste de licença** → adicione a sua conta Google (e a de quem for testar a compra).

## 7. Depois dos 14 dias

Painel → **Solicitar acesso à produção**. O Google faz umas perguntas sobre o teste (quantas pessoas, o que mudou). Aprovado, cria a versão de produção com o mesmo pacote (ou um novo, aumentando o número em `app/pubspec.yaml`).
