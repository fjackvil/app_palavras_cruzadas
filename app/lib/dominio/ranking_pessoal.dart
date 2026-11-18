import 'conquistas.dart';
import 'placar.dart';

/// Números de um jogador para o "Ranking pessoal" da primeira tela: ele
/// contra ele mesmo (semana atual × semana passada, melhores marcas).
class RankingPessoal {
  const RankingPessoal({
    required this.semana,
    required this.semanaPassada,
    required this.melhorPartida,
    required this.diasSeguidos,
    required this.conquistasGanhas,
    required this.desafios,
  });

  factory RankingPessoal.de(List<RegistroPlacar> doJogador, DateTime agora) {
    final inicio = Placar.inicioDaSemana(agora);
    final inicioPassada = inicio.subtract(const Duration(days: 7));
    var semana = 0;
    var passada = 0;
    var melhor = 0;
    for (final r in doJogador) {
      if (!r.quando.isBefore(inicio)) {
        semana += r.pontos;
      } else if (!r.quando.isBefore(inicioPassada)) {
        passada += r.pontos;
      }
      if (r.pontos > melhor) melhor = r.pontos;
    }
    return RankingPessoal(
      semana: semana,
      semanaPassada: passada,
      melhorPartida: melhor,
      diasSeguidos: maiorSequenciaDeDias(doJogador),
      conquistasGanhas: conquistas.where((c) => c.ganhou(doJogador)).length,
      desafios: doJogador.length,
    );
  }

  /// Pontos desta semana (desde segunda-feira).
  final int semana;
  final int semanaPassada;

  /// Maior pontuação numa partida só.
  final int melhorPartida;

  /// Maior sequência de dias seguidos jogando.
  final int diasSeguidos;
  final int conquistasGanhas;
  final int desafios;

  /// Frase comparando com a semana passada.
  String get comparacao {
    if (desafios == 0) return 'Termine um desafio para começar o seu ranking!';
    if (semana == 0) return 'Ainda sem pontos esta semana. Bora jogar?';
    if (semanaPassada == 0) return '$semana pontos esta semana. Bom começo!';
    final dif = semana - semanaPassada;
    if (dif > 0) return '📈 $dif pontos a mais que na semana passada!';
    if (dif == 0) return 'Empatado com a semana passada. Falta pouco!';
    return 'Faltam ${-dif} pontos para passar a semana passada.';
  }
}
