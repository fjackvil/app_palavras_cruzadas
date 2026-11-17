import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/plano.dart';

import '../apoio.dart';

void main() {
  const gratis = Plano(premium: false);
  const premium = Plano(premium: true);
  final temas = temasDoDisco();

  test('grátis: Leve e Médio; Premium: todos os níveis', () {
    expect(gratis.nivelLiberado(Nivel.leve), isTrue);
    expect(gratis.nivelLiberado(Nivel.medio), isTrue);
    expect(gratis.nivelLiberado(Nivel.dificil), isFalse);
    expect(gratis.nivelEfetivo(Nivel.superDificil), Nivel.medio);
    expect(premium.nivelEfetivo(Nivel.superDificil), Nivel.superDificil);
  });

  test('grátis libera os 10 temas marcados como gratuitos', () {
    final livres = temas.where(gratis.temaLiberado).toList();
    expect(livres, hasLength(10));
    expect(temas.where(premium.temaLiberado), hasLength(temas.length));
    // Os gratuitos servem para os dois níveis do plano grátis.
    for (final n in PlanoGratis.niveis) {
      expect(livres.where((t) => t.disponivelPara(n)), isNotEmpty);
    }
  });

  test('limites por dia e de jogadores', () {
    expect(gratis.podeCriarJogador(1), isTrue);
    expect(gratis.podeCriarJogador(2), isFalse);
    expect(premium.podeCriarJogador(4), isTrue);
    expect(gratis.podeComecarDesafio(2), isTrue);
    expect(gratis.podeComecarDesafio(3), isFalse);
    expect(gratis.desafiosRestantes(1), 2);
    expect(premium.desafiosRestantes(9), isNull);
    expect(gratis.podeUsarDica(3), isFalse);
    expect(premium.podeUsarDica(99), isTrue);
  });
}
