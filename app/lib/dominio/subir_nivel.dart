import 'nivel.dart';

/// O que importa de uma partida encerrada para a oferta de subir de nível.
class ResumoPartida {
  const ResumoPartida({
    required this.nivel,
    required this.concluida,
    required this.dicas,
    required this.segundos,
    required this.tempoAlvoSegundos,
  });

  final Nivel nivel;

  /// false quando a pessoa desistiu e viu a resposta.
  final bool concluida;
  final int dicas;
  final int segundos;
  final int tempoAlvoSegundos;

  /// Rápido e sem dicas, como pede a especificação.
  bool get mandouBem =>
      concluida && dicas == 0 && segundos <= tempoAlvoSegundos;
}

/// "Se alguém completa 3 desafios seguidos rápido e sem dicas, o app
/// oferece subir de nível."
abstract final class SubirNivel {
  static const seguidos = 3;

  /// Próximo nível a oferecer, ou null. [recentes] vem da mais recente para
  /// a mais antiga. Conta só a sequência atual no nível da última partida,
  /// e oferece a cada 3 seguidas (se a pessoa recusar, pergunta de novo
  /// depois de mais 3).
  static Nivel? oferta(List<ResumoPartida> recentes, Nivel nivelDoPerfil) {
    if (recentes.isEmpty) return null;
    final nivel = recentes.first.nivel;
    if (nivel != nivelDoPerfil || nivel == Nivel.values.last) return null;
    var n = 0;
    for (final r in recentes) {
      if (r.nivel != nivel || !r.mandouBem) break;
      n++;
    }
    if (n == 0 || n % seguidos != 0) return null;
    return Nivel.values[nivel.index + 1];
  }
}
