import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/caca_palavras.dart';
import 'package:palavras_cruzadas/dominio/jogo_caca.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';

import '../apoio.dart';

void main() {
  final temas = temasDoDisco();

  /// Confere que cada palavra está na grade onde diz estar e na direção
  /// permitida pelo nível.
  void conferir(DesafioCaca d) {
    final regras = RegrasCaca.de(d.nivel);
    expect(d.letras, hasLength(d.tamanho * d.tamanho));
    expect(d.letras.every((l) => RegExp(r'^[A-Z]$').hasMatch(l)), isTrue);
    expect(d.palavras, hasLength(regras.quantidade));
    for (final p in d.palavras) {
      expect(regras.direcoes, contains(p.direcao));
      final lidas = p.casas.map((c) => d.letra(c.$1, c.$2)).join();
      expect(lidas, p.resposta);
      for (final (l, c) in p.casas) {
        expect(l >= 0 && l < d.tamanho && c >= 0 && c < d.tamanho, isTrue);
      }
    }
    // Nenhuma palavra é pedaço de outra.
    for (final a in d.palavras) {
      for (final b in d.palavras) {
        if (!identical(a, b)) expect(b.resposta.contains(a.resposta), isFalse);
      }
    }
  }

  for (final nivel in Nivel.values) {
    test('grades válidas no ${nivel.nome}, misturado e cada tema', () {
      final visiveis = temas.where((t) => temaServeParaCaca(t, nivel));
      expect(visiveis.length, greaterThan(40));
      for (var s = 0; s < 5; s++) {
        conferir(
          const GeradorCaca().gerar(
            temas: visiveis.toList(),
            nivel: nivel,
            semente: s,
          ),
        );
      }
      for (final t in visiveis) {
        conferir(
          const GeradorCaca().gerar(temas: [t], nivel: nivel, semente: 7),
        );
      }
    });
  }

  test('todos os níveis usam as 8 direções', () {
    for (final nivel in Nivel.values) {
      final usadas = <Direcao>{};
      for (var s = 0; s < 30; s++) {
        final d = const GeradorCaca().gerar(
          temas: temas,
          nivel: nivel,
          semente: s,
        );
        usadas.addAll(d.palavras.map((p) => p.direcao));
      }
      expect(usadas, Direcao.values.toSet(), reason: nivel.nome);
    }
  });

  test('mesma semente, mesma grade; JSON de ida e volta', () {
    final a = const GeradorCaca().gerar(
      temas: temas,
      nivel: Nivel.dificil,
      semente: 3,
    );
    final b = const GeradorCaca().gerar(
      temas: temas,
      nivel: Nivel.dificil,
      semente: 3,
    );
    expect(a.paraJson(), b.paraJson());
    expect(DesafioCaca.deJson(a.paraJson()).paraJson(), a.paraJson());
    expect(a.id, startsWith('caca:dificil:'));
  });

  group('jogo', () {
    final d = const GeradorCaca().gerar(
      temas: temas,
      nivel: Nivel.superDificil,
      semente: 11,
    );

    test('achar arrastando nos dois sentidos e não achar fora da linha', () {
      final jogo = JogoCaca(d);
      final p = d.palavras.first;
      final (l1, c1) = p.casa(0);
      final (l2, c2) = p.casa(p.tamanho - 1);
      expect(jogo.tentar(l2, c2, l1, c1), 0);
      expect(jogo.encontradas, {0});
      // Achar de novo não conta.
      expect(jogo.tentar(l1, c1, l2, c2), isNull);
      // Linha torta não vale.
      expect(jogo.linhaEntre(0, 0, 1, 2), isNull);
    });

    test('seleção por dois toques', () {
      final jogo = JogoCaca(d);
      final p = d.palavras[1];
      final (l1, c1) = p.casa(0);
      final (l2, c2) = p.casa(p.tamanho - 1);
      expect(jogo.tocar(l1, c1), isNull);
      expect(jogo.inicioToque, (l1, c1));
      expect(jogo.tocar(l2, c2), 1);
      expect(jogo.inicioToque, isNull);
    });

    test('achar todas conclui; dica custa pontos; salvar e retomar', () {
      final jogo = JogoCaca(d);
      expect(jogo.dica(), d.palavras.first);
      for (final p in d.palavras) {
        final (l1, c1) = p.casa(0);
        final (l2, c2) = p.casa(p.tamanho - 1);
        jogo.tentar(l1, c1, l2, c2);
      }
      expect(jogo.concluido, isTrue);
      expect(jogo.pontuacao.custoDicas, 15);
      expect(jogo.pontuacao.bonusSemDica, 0);

      final volta = JogoCaca.deJson(d, jogo.paraJson());
      expect(volta.concluido, isTrue);
      expect(volta.dicasUsadas, 1);
    });
  });
}
