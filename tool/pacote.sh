#!/usr/bin/env bash
# Gera o pacote do app com o código ofuscado (nomes trocados por letras sem
# sentido, para dificultar quem tentar estudar ou alterar o app).
#
#   tool/pacote.sh loja    -> .aab para a Play Store
#   tool/pacote.sh teste   -> APK com o Premium liberado, só para o seu celular
#
# Os "símbolos" (o mapa para ler relatórios de erro do código ofuscado) ficam
# em app/simbolos/<versão>-<tipo>/. Eles NÃO vão para o Git. Guarde uma cópia
# dos símbolos de cada versão enviada à loja (por exemplo no Google Drive):
# sem eles, os erros dessa versão não dão para ler.
set -euo pipefail

tipo="${1:-}"
cd "$(dirname "$0")/../app"
versao="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
simbolos="simbolos/${versao}-${tipo}"
ofuscar=(--obfuscate "--split-debug-info=${simbolos}")

case "$tipo" in
  loja)
    if [ ! -f android/key.properties ]; then
      echo "Falta android/key.properties (a chave de upload). Veja docs/continuar-aqui.md." >&2
      exit 1
    fi
    flutter build appbundle --release "${ofuscar[@]}"
    echo
    echo "Pacote da loja: app/build/app/outputs/bundle/release/app-release.aab (versão ${versao})"
    ;;
  teste)
    flutter build apk --release --split-per-abi "${ofuscar[@]}" \
      --dart-define=PREMIUM_LIBERADO=true
    mkdir -p build/teste
    cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
      build/teste/palavras-cruzadas-teste-premium.apk
    echo
    echo "APK de teste: app/build/teste/palavras-cruzadas-teste-premium.apk (versão ${versao})"
    ;;
  *)
    echo "Uso: tool/pacote.sh loja|teste" >&2
    exit 1
    ;;
esac
echo "Símbolos: app/${simbolos} (guarde uma cópia; não vão para o Git)"
