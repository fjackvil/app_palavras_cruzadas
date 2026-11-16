# App de palavras cruzadas e caça-palavras (Android)

Antes de qualquer tarefa, leia `docs/especificacao.md`. Ela tem todas as decisões do produto.

## Decisões que não mudam sem conversar antes

- App em Flutter (Dart), só Android por enquanto. Organização: `com.vileladigit`. Projeto em `app/`.
- Textos do app em português do Brasil.
- Beta: palavras em arquivos JSON em `app/assets/palavras/`, um por tema, no formato da especificação. As grades são montadas no próprio app; o desafio diário usa a data como semente.
- Dados dos jogadores só no celular (Drift/SQLite). Não há login para jogar.
- Sem anúncios e sem SDKs de rastreio (AdMob, Firebase Analytics, Crashlytics).
- Compras pelo plugin `in_app_purchase` (Google Play Billing).
- Grupos e Supabase só depois do beta.

## Como trabalhar

- Siga o roadmap da especificação, uma fase por vez, começando pela fase 1.
- Nunca faça commit de chaves ou segredos: `.jks`, `key.properties`, `.env`, chave `service_role` do Supabase.
- Ao terminar uma tarefa, rode `flutter analyze` e os testes dentro de `app/`.
