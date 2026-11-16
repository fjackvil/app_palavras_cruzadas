import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/pontuacao.dart';
import 'package:flutter_test/flutter_test.dart';

Pontuacao calc({
  Nivel nivel = Nivel.leve,
  required int letras,
  int segundos = 9999,
  int alvo = 100,
  int dicasLetra = 0,
  int dicasPalavra = 0,
}) => Pontuacao.calcular(
  nivel: nivel,
  letras: letras,
  segundos: segundos,
  tempoAlvoSegundos: alvo,
  dicasLetra: dicasLetra,
  dicasPalavra: dicasPalavra,
);

void main() {
  test('1 ponto por letra vezes o multiplicador do nível', () {
    expect(calc(letras: 20, dicasLetra: 1).base, 20);
    expect(calc(nivel: Nivel.medio, letras: 20, dicasLetra: 1).base, 30);
    expect(calc(nivel: Nivel.superDificil, letras: 20, dicasLetra: 1).base, 60);
  });

  test('um desafio Leve típico vale algumas dezenas de pontos', () {
    // 6 palavras (~25 letras), no tempo-alvo, sem dicas.
    final p = calc(letras: 25, segundos: 200, alvo: 200);
    expect(p.total, inInclusiveRange(25, 45));
  });

  test('bônus de tempo: 50% na hora, 25% no alvo, zero no dobro', () {
    int bonus(int s) =>
        calc(letras: 100, segundos: s, dicasLetra: 1).bonusTempo;
    expect(bonus(0), 50);
    expect(bonus(100), 25);
    expect(bonus(200), 0);
    expect(bonus(500), 0);
  });

  test('sem dicas ganha 20%; dicas custam 2 e 5', () {
    final sem = calc(letras: 100, segundos: 200);
    expect(sem.bonusSemDica, 20);
    expect(sem.total, 120);
    final com = calc(
      letras: 100,
      segundos: 200,
      dicasLetra: 2,
      dicasPalavra: 1,
    );
    expect(com.bonusSemDica, 0);
    expect(com.custoDicas, 9);
    expect(com.total, 91);
  });

  test('o total nunca fica negativo', () {
    expect(calc(letras: 3, segundos: 500, alvo: 10, dicasPalavra: 3).total, 0);
  });
}
