import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/placar.dart';
import 'package:palavras_cruzadas/dominio/ranking_pessoal.dart';

RegistroPlacar r(DateTime quando, int pontos) => RegistroPlacar(
  perfilId: 1,
  modo: 'cruzadas',
  nivel: Nivel.leve,
  temas: const ['animais'],
  pontos: pontos,
  quando: quando,
);

void main() {
  // Quarta-feira, 18/11/2026. A semana começa na segunda, 16/11.
  final agora = DateTime(2026, 11, 18, 10);

  test('sem desafios', () {
    final k = RankingPessoal.de(const [], agora);
    expect(k.semana, 0);
    expect(k.comparacao, contains('Termine um desafio'));
  });

  test('soma a semana, a passada e acha a melhor partida', () {
    final k = RankingPessoal.de([
      r(DateTime(2026, 11, 16, 9), 30),
      r(DateTime(2026, 11, 17, 9), 50),
      r(DateTime(2026, 11, 10, 9), 40),
      r(DateTime(2026, 11, 1, 9), 99),
    ], agora);
    expect(k.semana, 80);
    expect(k.semanaPassada, 40);
    expect(k.melhorPartida, 99);
    expect(k.diasSeguidos, 2);
    expect(k.desafios, 4);
    expect(k.comparacao, contains('40 pontos a mais'));
  });

  test('abaixo da semana passada diz quanto falta', () {
    final k = RankingPessoal.de([
      r(DateTime(2026, 11, 17), 10),
      r(DateTime(2026, 11, 12), 25),
    ], agora);
    expect(k.comparacao, 'Faltam 15 pontos para passar a semana passada.');
  });
}
