# Onde paramos e como continuar

Última atualização: 16/11/2026.

Este arquivo tem duas partes:

1. **Onde paramos:** o que já está pronto, o que falta e as decisões tomadas.
2. **Passo a passo no Windows 11:** tudo o que precisa instalar para testar o app em outra máquina.

---

## 1. Onde paramos

### O que já funciona

O app se chama **Palavras Cruzadas** (identificador `com.vileladigit.palavrascruzadas`) e tem dois jogos.

**Palavras cruzadas**

- Grade no estilo americano e teclado próprio.
- Quatro níveis: Leve, Médio, Difícil e Super difícil.
- Dicas de letra e de palavra, botão "Verificar".
- A palavra certa passa sozinha para a próxima.
- Tocar numa letra de outra palavra mostra a dica dela.
- Zoom com dois dedos nas grades grandes.

**Caça-palavras**

- Grades de 8×8 a 12×12, com palavras escondidas nas 8 direções em todos os níveis.
- Para achar uma palavra: arrastar o dedo, ou tocar na primeira e na última letra.
- A dica marca a primeira letra.
- No Super difícil, a lista mostra só as dicas, sem as palavras.

**Comum aos dois jogos**

- Até 5 jogadores no celular, cada um com avatar desenhado ou foto (galeria ou câmera).
- Conteúdo: 64 temas e 3.224 palavras. Crianças só veem temas infantis.
- Pontuação: 1 ponto por letra × nível, bônus de tempo de até +50% e bônus de +20% sem dica. As dicas custam 2 (letra) e 5 (palavra).
- O cronômetro só começa na primeira jogada.
- Salvamento automático. "Desistir" manda o desafio para Pendentes, e de lá dá para continuar ou ver a resposta.
- Desafio do dia, um para cada jogo, com sequência de dias 🔥.
- Oferta para subir de nível depois de 3 desafios seguidos rápidos e sem dica.
- Tela de abertura com caça-palavras animado, tela **Como jogar** (9 páginas), ícone de cruzadas e o logo da Vilela Digit no rodapé.

Para testar: 124 testes automáticos, todos passando (`flutter test` dentro de `app/`).

### O que falta

**Fase 3 (em andamento)**

- [x] Placar da família: ranking entre os jogadores do aparelho, por semana (ou desde o início), jogo, nível e tema. Abre pelo botão na primeira tela ou pelo 🏆 na tela do jogador.
- [ ] Recordes pessoais: melhor tempo e maior pontuação.
- [ ] Conquistas, como 7 dias seguidos ou 10 desafios sem dica.
- [ ] Botão de compartilhar resultado (texto pelo WhatsApp etc.).

**Pendências**

- [ ] **Testar tudo no aparelho de verdade.** No Linux, o emulador ficou travando para o Fernando. Do lado do Android o app respondia normalmente (comandos `adb` funcionavam e as telas abriam em menos de 0,5 s). A suspeita é a janela do emulador naquele computador.
- [ ] Revisão humana do conteúdo: ver `docs/revisao-conteudo.md`.
- [ ] Os pontos feitos antes da mudança de pontuação (por exemplo, os 225 do Theo no emulador do Linux) continuam na escala antiga. Na máquina nova o banco começa vazio.

**Fase 4**

Ainda não começou: Google Play Billing, Premium, política de privacidade, chave de assinatura e teste fechado.

### Decisões tomadas nesta etapa

Todas registradas também em `docs/especificacao.md`.

- Nome: "Palavras Cruzadas", no lugar de "Cruza Letra".
- O ícone do app é um desenho de cruzadas. O logo da Vilela Digit fica dentro do app.
- Caça-palavras com todas as direções em todos os níveis.
- Pontuação 10 vezes menor do que a proposta original.
- Cronômetro começa na primeira jogada.
- Foto do jogador pelo plugin `image_picker`. A foto fica só no celular.

### Para o Claude Code na outra máquina

Abra a pasta do repositório e peça, por exemplo:

> Leia o CLAUDE.md e o docs/continuar-aqui.md e continue a fase 3 pelo placar da família.

---

## 2. Passo a passo no Windows 11

### Links para baixar

Todos são sites oficiais. Dá para instalar pelo link ou pelo comando `winget` de cada passo; os dois dão no mesmo.

| Programa | Para que serve | Link |
| --- | --- | --- |
| Git para Windows | Baixar e enviar o projeto do GitHub | <https://git-scm.com/download/win> |
| Android Studio | Android SDK e emulador | <https://developer.android.com/studio> |
| Flutter (stable) | Compilar e rodar o app | <https://docs.flutter.dev/get-started/install/windows/mobile> |
| Flutter, todas as versões (arquivo .zip) | Se quiser escolher a versão (use 3.50 ou mais nova) | <https://docs.flutter.dev/release/archive> |
| VS Code (opcional) | Editor de código | <https://code.visualstudio.com/download> |
| Extensão Flutter do VS Code (opcional) | Rodar e depurar pelo editor | <https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter> |
| Claude Code (opcional) | Continuar o desenvolvimento com o Claude | <https://claude.com/claude-code> |
| Chaves SSH do GitHub | Página para cadastrar a chave da conta fjackvil (entre com ela antes) | <https://github.com/settings/keys> |
| Repositório do projeto | Ver o código e os commits no navegador | <https://github.com/fjackvil/app_palavras_cruzadas> |

Os comandos abaixo são para o **PowerShell**: menu Iniciar, digite "PowerShell" e abra. Onde aparece "reinicie o PowerShell", feche a janela e abra outra, para ele enxergar os programas novos.

### Passo 1: Git

Download: <https://git-scm.com/download/win> (pode aceitar todas as opções padrão do instalador), ou pelo PowerShell:

```powershell
winget install --id Git.Git -e
```

Reinicie o PowerShell e confira com `git --version`.

### Passo 2: chave SSH da conta pessoal do GitHub (fjackvil)

O repositório é da conta pessoal. Se essa máquina também tiver a conta de trabalho, **não mexa na configuração global do git**. Use a chave e o apelido abaixo, como no Linux.

1. Crie a chave:

   ```powershell
   ssh-keygen -t ed25519 -C "pc-windows-pessoal" -f $HOME\.ssh\github_fjackvil
   ```

   Pode deixar a senha vazia ou criar uma.

2. Crie o arquivo `C:\Users\<seu usuário>\.ssh\config`, sem extensão, com este conteúdo:

   ```
   Host github-pessoal
       HostName github.com
       User git
       IdentityFile ~/.ssh/github_fjackvil
       IdentitiesOnly yes
   ```

3. Copie a chave pública:

   ```powershell
   Get-Content $HOME\.ssh\github_fjackvil.pub | Set-Clipboard
   ```

4. No GitHub, **entrando com a conta fjackvil**, abra <https://github.com/settings/keys> (Settings → SSH and GPG keys) → New SSH key, cole a chave e salve.

5. Teste a conexão. A resposta deve ser "Hi fjackvil!":

   ```powershell
   ssh -T git@github-pessoal
   ```

### Passo 3: baixar o projeto

```powershell
mkdir C:\dev
cd C:\dev
git clone git@github-pessoal:fjackvil/app_palavras_cruzadas.git
cd app_palavras_cruzadas
git config user.name "Fernando Jackson Vilela"
git config user.email "<seu e-mail pessoal>"
```

O `git config` sem `--global` vale só para este projeto.

### Passo 4: Android Studio, SDK e emulador

1. Instale o Android Studio. Download: <https://developer.android.com/studio>, ou pelo PowerShell:

   ```powershell
   winget install --id Google.AndroidStudio -e
   ```

2. Abra o Android Studio e siga o assistente com a opção **Standard**. Ele baixa o Android SDK em `C:\Users\<você>\AppData\Local\Android\Sdk`.

3. Ainda no Android Studio, abra **More Actions → SDK Manager → SDK Tools** e marque:
   - Android SDK Command-line Tools (latest)
   - Android SDK Platform-Tools
   - Android Emulator

   Depois clique em Apply.

4. Ligue a aceleração do emulador. Ela evita a lentidão que tivemos no Linux.
   1. Menu Iniciar → "Ativar ou desativar recursos do Windows".
   2. Marque **Plataforma do Hipervisor do Windows** e dê OK.
   3. Reinicie o computador.
   4. Se o emulador reclamar de virtualização, ative "Intel VT-x" ou "AMD-V/SVM" na BIOS.

5. Crie o celular virtual:
   1. Abra **More Actions → Virtual Device Manager → Create device**.
   2. Escolha **Pixel 7** e o sistema **API 34** (a versão com Google Play, x86_64).
   3. Em "Show Advanced Settings", coloque **RAM 4096 MB** e **Graphics: Hardware**.

### Passo 5: Flutter

1. Baixe o Flutter **stable** (versão 3.50 ou mais nova), no arquivo `.zip`. Extraia para `C:\dev\flutter`.
   - Página de instalação: <https://docs.flutter.dev/get-started/install/windows/mobile>
   - Lista de todas as versões, se precisar de uma específica: <https://docs.flutter.dev/release/archive> (aba Windows, canal Stable)
   - Não use `C:\Program Files`: o Flutter precisa escrever na pasta.
   - Também dá para baixar com o git: `git clone -b stable https://github.com/flutter/flutter.git C:\dev\flutter`.

2. Coloque o Flutter no PATH:

   ```powershell
   [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";C:\dev\flutter\bin", "User")
   ```

   Reinicie o PowerShell.

3. Configure e confira:

   ```powershell
   flutter config --no-analytics
   flutter doctor --android-licenses
   flutter doctor
   ```

   - No `--android-licenses`, responda `y` a todas.
   - O `flutter doctor` precisa mostrar ✓ em "Flutter" e em "Android toolchain". Avisos sobre Chrome, Visual Studio ou web podem ser ignorados: o app é só Android.

### Passo 6: rodar os testes e o app

```powershell
cd C:\dev\app_palavras_cruzadas\app
flutter pub get
flutter analyze
flutter test
```

O resultado esperado é "No issues found!" e "All tests passed!".

Para abrir no emulador:

1. No Android Studio, abra o Device Manager e toque em ▶ no Pixel 7. Espere o Android ligar.
2. Rode, no PowerShell:

   ```powershell
   flutter devices
   flutter run --release
   ```

   O `flutter devices` precisa listar o emulador.

Use **`--release`**. Sem ele, o app roda em modo de depuração, que no emulador fica muito lento e parece travado.

Teclas no PowerShell enquanto o app roda:
- `q` fecha o app.
- Para ver uma alteração no código com `--release`, feche com `q` e rode `flutter run --release` de novo.

### Passo 7 (opcional): instalar no celular sem modo desenvolvedor

Não precisa ligar o modo desenvolvedor, então os apps de banco continuam funcionando.

1. Gere o arquivo do app:

   ```powershell
   cd C:\dev\app_palavras_cruzadas\app
   flutter build apk --release
   ```

   O arquivo fica em `app\build\app\outputs\flutter-apk\app-release.apk` e tem cerca de 23 MB.

2. Mande para o celular por WhatsApp (para você mesmo), Google Drive ou cabo USB, como arquivo.
3. No celular, toque no arquivo. O Android pede para permitir instalar apps "desta fonte" (do WhatsApp, do Drive etc.). Permita só para ela e instale.
4. Por enquanto o app vem assinado com a chave de teste do Flutter. Isso serve para testar, mas não para a Play Store: a chave definitiva é da fase 4 e **nunca vai para o git**.

### Passo 8 (opcional): Claude Code e editor

- **VS Code:** download em <https://code.visualstudio.com/download>, ou `winget install --id Microsoft.VisualStudioCode -e`. Depois instale a extensão Flutter (ela instala a de Dart junto): <https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter>.
- **Claude Code:** download e instruções em <https://claude.com/claude-code>. Depois abra a pasta `C:\dev\app_palavras_cruzadas` e peça para continuar a partir deste arquivo.

### Problemas comuns

| Problema | O que fazer |
| --- | --- |
| `flutter` não é reconhecido | O PATH não pegou. Reinicie o PowerShell, ou confira se `C:\dev\flutter\bin` está nas variáveis de ambiente do usuário. |
| "Android license status unknown" | Rode `flutter doctor --android-licenses` e aceite tudo. |
| `cmdline-tools component is missing` | Volte ao Passo 4.3 e marque "Android SDK Command-line Tools". |
| Emulador muito lento ou travando | Confira o Passo 4.4 (hipervisor) e se o Graphics está em "Hardware". Use `flutter run --release`. |
| `Permission denied (publickey)` no git | Teste `ssh -T git@github-pessoal`. Confira se a chave foi adicionada na conta **fjackvil** e se o arquivo `config` não ficou com extensão `.txt`. |
| Primeiro `flutter run` demorado (vários minutos) | Normal: ele baixa o Gradle e as dependências do Android só na primeira vez. |
