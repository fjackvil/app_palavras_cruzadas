/// Funções de texto usadas na grade.
library;

const _semAcento = {
  'Á': 'A', 'À': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', //
  'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E', //
  'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I', //
  'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O', //
  'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U', //
  'Ç': 'C', 'Ñ': 'N',
};

/// Converte a palavra para o formato da grade: maiúsculas, sem acentos,
/// sem espaços nem hífens. "Ação" vira "ACAO".
String paraGrade(String palavra) {
  final buffer = StringBuffer();
  for (final rune in palavra.toUpperCase().runes) {
    final letra = String.fromCharCode(rune);
    final trocada = _semAcento[letra] ?? letra;
    if (RegExp(r'^[A-Z]$').hasMatch(trocada)) buffer.write(trocada);
  }
  return buffer.toString();
}
