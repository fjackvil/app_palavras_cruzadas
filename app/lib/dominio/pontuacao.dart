import 'dart:math';

import 'nivel.dart';

/// Regras de pontuação da especificação.
class Pontuacao {
  const Pontuacao({
    required this.base,
    required this.bonusTempo,
    required this.bonusSemDica,
    required this.custoDicas,
  });

  /// 1 ponto por letra (antes eram 10; os números ficavam altos demais).
  static const pontosPorLetra = 1;
  static const custoDicaLetra = 2;
  static const custoDicaPalavra = 5;

  /// Bônus máximo de tempo (+50%), quando o tempo é quase zero.
  static const bonusTempoMaximo = 0.5;
  static const bonusSemDicaPercentual = 0.2;

  /// Calcula os pontos de um desafio concluído.
  ///
  /// Bônus de tempo: +50% se terminar na hora, +25% no tempo-alvo e cai até
  /// zero no dobro do tempo-alvo.
  factory Pontuacao.calcular({
    required Nivel nivel,
    required int letras,
    required int segundos,
    required int tempoAlvoSegundos,
    required int dicasLetra,
    required int dicasPalavra,
  }) {
    final base = (letras * pontosPorLetra * nivel.multiplicador).round();
    final alvo = max(1, tempoAlvoSegundos);
    final fracao = (1 - segundos / (2 * alvo)).clamp(0.0, 1.0);
    final semDica = dicasLetra == 0 && dicasPalavra == 0;
    return Pontuacao(
      base: base,
      bonusTempo: (base * bonusTempoMaximo * fracao).round(),
      bonusSemDica: semDica ? (base * bonusSemDicaPercentual).round() : 0,
      custoDicas: dicasLetra * custoDicaLetra + dicasPalavra * custoDicaPalavra,
    );
  }

  final int base;
  final int bonusTempo;
  final int bonusSemDica;
  final int custoDicas;

  int get total => max(0, base + bonusTempo + bonusSemDica - custoDicas);
}
