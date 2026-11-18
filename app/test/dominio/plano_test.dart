import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dados/premium.dart';
import 'package:palavras_cruzadas/dominio/caca_palavras.dart';
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

  test('grátis libera exatamente um tema por categoria', () {
    final livres = temas.where(gratis.temaLiberado).toList();
    final categorias = temas.map((t) => t.categoria).toSet();
    expect(livres, hasLength(categorias.length));
    expect(livres.map((t) => t.categoria).toSet(), categorias);
    // Cada tema grátis serve para os dois jogos nos níveis do grátis.
    for (final t in livres) {
      for (final n in PlanoGratis.niveis.where((n) => !n.soComDesenho)) {
        expect(t.disponivelPara(n), isTrue, reason: '${t.id} ${n.name}');
        expect(temaServeParaCaca(t, n), isTrue, reason: '${t.id} caça');
      }
    }
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
    expect(gratis.podeGuardarPendente(2), isTrue);
    expect(gratis.podeGuardarPendente(3), isFalse);
    expect(premium.podeGuardarPendente(50), isTrue);
    expect(premium.podeUsarDica(99), isTrue);
  });

  test('o Premium de teste fica desligado nos builds normais', () {
    expect(ServicoPremium.liberadoParaTeste, isFalse);
  });
}
