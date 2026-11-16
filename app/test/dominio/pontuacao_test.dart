import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/pontuacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('10 pontos por letra vezes o multiplicador do nível', () {
    final leve = Pontuacao.calcular(
      nivel: Nivel.leve,
      letras: 20,
      segundos: 9999,
      tempoAlvoSegundos: 100,
      dicasLetra: 1,
      dicasPalavra: 0,
    );
    expect(leve.base, 200);
    final medio = Pontuacao.calcular(
      nivel: Nivel.medio,
      letras: 20,
      segundos: 9999,
      tempoAlvoSegundos: 100,
      dicasLetra: 1,
      dicasPalavra: 0,
    );
    expect(medio.base, 300);
  });

  test('bônus de tempo: 50% na hora, 25% no alvo, zero no dobro', () {
    Pontuacao com(int s) => Pontuacao.calcular(
      nivel: Nivel.leve,
      letras: 10,
      segundos: s,
      tempoAlvoSegundos: 100,
      dicasLetra: 1,
      dicasPalavra: 0,
    );
    expect(com(0).bonusTempo, 50);
    expect(com(100).bonusTempo, 25);
    expect(com(200).bonusTempo, 0);
    expect(com(500).bonusTempo, 0);
  });

  test('sem dicas ganha 20%; dicas custam 15 e 50', () {
    final sem = Pontuacao.calcular(
      nivel: Nivel.leve,
      letras: 10,
      segundos: 200,
      tempoAlvoSegundos: 100,
      dicasLetra: 0,
      dicasPalavra: 0,
    );
    expect(sem.bonusSemDica, 20);
    expect(sem.total, 120);
    final com = Pontuacao.calcular(
      nivel: Nivel.leve,
      letras: 10,
      segundos: 200,
      tempoAlvoSegundos: 100,
      dicasLetra: 2,
      dicasPalavra: 1,
    );
    expect(com.bonusSemDica, 0);
    expect(com.custoDicas, 80);
    expect(com.total, 20);
  });

  test('o total nunca fica negativo', () {
    final p = Pontuacao.calcular(
      nivel: Nivel.leve,
      letras: 3,
      segundos: 500,
      tempoAlvoSegundos: 10,
      dicasLetra: 0,
      dicasPalavra: 3,
    );
    expect(p.total, 0);
  });
}
