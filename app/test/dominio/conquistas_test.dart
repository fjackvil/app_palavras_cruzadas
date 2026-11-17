import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/conquistas.dart';
import 'package:palavras_cruzadas/dominio/placar.dart';

RegistroPlacar r(
  int id, {
  DateTime? quando,
  int dicas = 0,
  int pontos = 10,
  String desafioId = 'cruzadas:leve:animais:1',
  String modo = 'cruzadas',
}) => RegistroPlacar.doDesafio(
  perfilId: 1,
  modo: modo,
  desafioId: desafioId,
  pontos: pontos,
  quando: quando ?? DateTime(2026, 11, 17, 10),
  partidaId: id,
  dicas: dicas,
);

Conquista c(String id) => conquistas.firstWhere((x) => x.id == id);

void main() {
  test('ids das conquistas são únicos', () {
    final ids = conquistas.map((x) => x.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('maior sequência de dias, mesmo virando o mês', () {
    final dias = [
      r(1, quando: DateTime(2026, 10, 30, 9)),
      r(2, quando: DateTime(2026, 10, 31, 22)),
      r(3, quando: DateTime(2026, 11, 1, 8)),
      r(4, quando: DateTime(2026, 11, 1, 20)), // mesmo dia não conta 2 vezes
      r(5, quando: DateTime(2026, 11, 5)),
    ];
    expect(maiorSequenciaDeDias(dias), 3);
    expect(maiorSequenciaDeDias([]), 0);
  });

  test('progresso das conquistas', () {
    final rs = [
      r(1),
      r(2, dicas: 2),
      r(3, desafioId: 'caca:superDificil:frutas:9', modo: 'caca_palavras'),
      r(4, desafioId: 'cruzadas:diario:leve:2026-11-17'),
    ];
    expect(c('primeiro').ganhou(rs), isTrue);
    expect(c('sem_dica').progresso(rs), 3);
    expect(c('caca').progresso(rs), 1);
    expect(c('cruzadas').progresso(rs), 3);
    expect(c('diario').progresso(rs), 1);
    expect(c('temas').progresso(rs), 2);
    expect(c('super').ganhou(rs), isTrue);
    expect(c('dificil').ganhou(rs), isFalse);
  });

  test('conquistas novas: só as que o último desafio liberou', () {
    final antes = [r(1)];
    expect(conquistasNovas(antes, 1).map((x) => x.id), contains('primeiro'));
    final depois = [r(1), r(2, desafioId: 'cruzadas:dificil:frutas:2')];
    final novas = conquistasNovas(depois, 2).map((x) => x.id);
    expect(novas, contains('dificil'));
    expect(novas, isNot(contains('primeiro')));
  });
}
