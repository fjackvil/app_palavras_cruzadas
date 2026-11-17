import 'nivel.dart';
import 'placar.dart';

/// Recordes de um jogo (cruzadas ou caça-palavras) num nível.
class RecordeNivel {
  const RecordeNivel({
    required this.modo,
    required this.nivel,
    required this.desafios,
    required this.maiorPontuacao,
    required this.melhorTempo,
  });

  final String modo;
  final Nivel nivel;
  final int desafios;
  final int maiorPontuacao;

  /// Em segundos.
  final int melhorTempo;
}

/// Maior pontuação num tema jogado sozinho.
class RecordeTema {
  const RecordeTema({
    required this.tema,
    required this.desafios,
    required this.maiorPontuacao,
  });

  final String tema;
  final int desafios;
  final int maiorPontuacao;
}

/// Recordes pessoais de um jogador, calculados dos desafios concluídos.
class Recordes {
  const Recordes({
    required this.desafios,
    required this.pontos,
    required this.porNivel,
    required this.porTema,
  });

  /// [registros] só do jogador (já filtrados) e só concluídos.
  factory Recordes.de(List<RegistroPlacar> registros) {
    final porNivel = <(String, Nivel), List<RegistroPlacar>>{};
    final porTema = <String, List<RegistroPlacar>>{};
    for (final r in registros) {
      porNivel.putIfAbsent((r.modo, r.nivel), () => []).add(r);
      if (r.temas.length == 1) {
        porTema.putIfAbsent(r.temas.single, () => []).add(r);
      }
    }
    final niveis =
        [
          for (final MapEntry(key: (modo, nivel), value: lista)
              in porNivel.entries)
            RecordeNivel(
              modo: modo,
              nivel: nivel,
              desafios: lista.length,
              maiorPontuacao: lista
                  .map((r) => r.pontos)
                  .reduce((a, b) => a > b ? a : b),
              melhorTempo: lista
                  .map((r) => r.segundos)
                  .reduce((a, b) => a < b ? a : b),
            ),
        ]..sort((a, b) {
          final m = a.modo.compareTo(b.modo);
          return m != 0 ? m : a.nivel.index.compareTo(b.nivel.index);
        });
    final temas = [
      for (final MapEntry(key: tema, value: lista) in porTema.entries)
        RecordeTema(
          tema: tema,
          desafios: lista.length,
          maiorPontuacao: lista
              .map((r) => r.pontos)
              .reduce((a, b) => a > b ? a : b),
        ),
    ]..sort((a, b) => b.maiorPontuacao.compareTo(a.maiorPontuacao));
    return Recordes(
      desafios: registros.length,
      pontos: registros.fold(0, (s, r) => s + r.pontos),
      porNivel: niveis,
      porTema: temas,
    );
  }

  final int desafios;
  final int pontos;
  final List<RecordeNivel> porNivel;
  final List<RecordeTema> porTema;

  /// O que o desafio [novo] bateu, comparando com os anteriores do mesmo
  /// jogo e nível (o primeiro desafio de um nível não conta como recorde).
  static List<String> batidos(
    RegistroPlacar novo,
    List<RegistroPlacar> anteriores,
  ) {
    final mesmos = anteriores
        .where(
          (r) =>
              r.partidaId != novo.partidaId &&
              r.modo == novo.modo &&
              r.nivel == novo.nivel,
        )
        .toList();
    if (mesmos.isEmpty) return const [];
    final bateu = <String>[];
    if (novo.pontos >
        mesmos.map((r) => r.pontos).reduce((a, b) => a > b ? a : b)) {
      bateu.add('Maior pontuação');
    }
    if (novo.segundos <
        mesmos.map((r) => r.segundos).reduce((a, b) => a < b ? a : b)) {
      bateu.add('Melhor tempo');
    }
    return bateu;
  }
}
