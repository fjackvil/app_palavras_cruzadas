import 'package:cruzaletra/dominio/desafio.dart';
import 'package:cruzaletra/dominio/gerador_cruzadas.dart';
import 'package:cruzaletra/dominio/nivel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio.dart';

/// Todas as sequências de 2+ letras seguidas na grade, com a posição.
Set<String> sequencias(DesafioCruzadas d) {
  final achadas = <String>{};
  for (final horizontal in [true, false]) {
    for (var a = 0; a < d.tamanho; a++) {
      var b = 0;
      while (b < d.tamanho) {
        final (l, c) = horizontal ? (a, b) : (b, a);
        if (d.ehBloqueada(l, c)) {
          b++;
          continue;
        }
        final inicio = b;
        final buffer = StringBuffer();
        while (b < d.tamanho) {
          final (ll, cc) = horizontal ? (a, b) : (b, a);
          if (d.ehBloqueada(ll, cc)) break;
          buffer.write(d.letra(ll, cc));
          b++;
        }
        if (buffer.length >= 2) {
          final (l0, c0) = horizontal ? (a, inicio) : (inicio, a);
          achadas.add('$l0,$c0,$horizontal,$buffer');
        }
      }
    }
  }
  return achadas;
}

void main() {
  final temas = temasDoDisco();
  const gerador = GeradorCruzadas();

  test('a mesma semente gera a mesma grade', () {
    final a = gerador.gerar(
      temas: temas,
      nivel: Nivel.medio,
      semente: 20261116,
    );
    final b = gerador.gerar(
      temas: temas,
      nivel: Nivel.medio,
      semente: 20261116,
    );
    expect(a.paraJson(), b.paraJson());
  });

  for (final nivel in Nivel.values) {
    for (final tema in [null, ...temas]) {
      test('grades válidas: ${nivel.nome}, ${tema?.nome ?? 'Misturado'}', () {
        for (var semente = 1; semente <= 15; semente++) {
          final d = gerador.gerar(
            temas: tema == null ? temas : [tema],
            nivel: nivel,
            semente: semente,
          );
          final minimo = nivel == Nivel.leve ? 4 : 8;
          expect(d.palavras.length, greaterThanOrEqualTo(minimo));

          final colocadas = <String>{};
          for (final p in d.palavras) {
            expect(
              p.tamanho,
              inInclusiveRange(nivel.minLetras, nivel.maxLetras),
            );
            for (var i = 0; i < p.tamanho; i++) {
              final (l, c) = p.casa(i);
              expect(d.letra(l, c), p.resposta[i], reason: 'letra em conflito');
            }
            expect(p.dica, isNotEmpty);
            colocadas.add(
              '${p.linha},${p.coluna},${p.horizontal},${p.resposta}',
            );
          }
          // Nenhuma sequência de letras fora das palavras colocadas.
          expect(sequencias(d), colocadas);

          // Numeração: crescente na ordem de leitura, a partir de 1.
          final inicios =
              d.palavras
                  .map((p) => d.indice(p.linha, p.coluna))
                  .toSet()
                  .toList()
                ..sort();
          for (final p in d.palavras) {
            expect(p.numero, inicios.indexOf(d.indice(p.linha, p.coluna)) + 1);
          }
        }
      });
    }
  }

  test('JSON de ida e volta mantém o desafio', () {
    final d = gerador.gerar(temas: temas, nivel: Nivel.leve, semente: 7);
    final volta = DesafioCruzadas.deJson(d.paraJson());
    expect(volta.paraJson(), d.paraJson());
    expect(volta.id, d.id);
  });
}
