import 'nivel.dart';

/// Página do app na Play Store. Só abre depois que o app for publicado;
/// antes disso o link mostra "item não encontrado".
const linkLoja =
    'https://play.google.com/store/apps/details?id=com.vileladigit.palavrascruzadas';

/// Texto que o jogador pode mandar pelo WhatsApp etc. depois de terminar.
/// Não leva o nome nem a idade de ninguém: só o desafio e o resultado.
String textoResultado({
  required bool caca,
  required Nivel nivel,
  required String? diario,
  required int pontos,
  required int segundos,
  required int dicas,
  required int palavras,
}) {
  final jogo = caca ? 'Caça-palavras' : 'Cruzadas';
  final m = segundos ~/ 60;
  final s = (segundos % 60).toString().padLeft(2, '0');
  final tempo = m > 0 ? '${m}min${s}s' : '${segundos}s';
  final titulo = diario != null
      ? '📅 Desafio do dia ${_data(diario)} · $jogo · ${nivel.nome}'
      : '${caca ? '🔍' : '✏️'} $jogo · ${nivel.nome}';
  final dicaTexto = dicas == 0
      ? 'sem nenhuma dica 💪'
      : dicas == 1
      ? 'com 1 dica'
      : 'com $dicas dicas';
  return [
    'Palavras Cruzadas',
    titulo,
    '⭐ $pontos pontos em ⏱ $tempo',
    '$palavras palavras, $dicaTexto',
    if (diario != null)
      'Consegue fazer melhor? É a mesma grade para todo mundo hoje!',
    '',
    'Baixe o app e jogue também: $linkLoja',
  ].join('\n');
}

/// Link que abre o WhatsApp já com o texto escrito; a pessoa só escolhe o
/// contato ou o grupo.
Uri linkWhatsApp(String texto) =>
    Uri.parse('https://wa.me/?text=${Uri.encodeComponent(texto)}');

/// O mesmo, pelo app do WhatsApp (abre direto, sem passar pelo navegador).
Uri linkAppWhatsApp(String texto) =>
    Uri.parse('whatsapp://send?text=${Uri.encodeComponent(texto)}');

/// '2026-11-17' → '17/11'.
String _data(String iso) {
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}' : iso;
}
