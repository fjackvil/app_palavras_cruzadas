import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/placar.dart';

void main() {
  // Quarta-feira, 18/11/2026. A semana começa na segunda, 16/11.
  final agora = DateTime(2026, 11, 18, 15);

  RegistroPlacar r(
    int perfil,
    int pontos, {
    String id = 'cruzadas:leve:animais:1',
    String modo = 'cruzadas',
    DateTime? quando,
  }) => RegistroPlacar.doDesafio(
    perfilId: perfil,
    modo: modo,
    desafioId: id,
    pontos: pontos,
    quando: quando ?? DateTime(2026, 11, 17),
  );

  test('lê nível e temas do id do desafio', () {
    final livre = r(
      1,
      0,
      id: 'caca:medio:animais+frutas:9',
      modo: 'caca_palavras',
    );
    expect(livre.nivel, Nivel.medio);
    expect(livre.temas, ['animais', 'frutas']);
    final diario = r(1, 0, id: 'cruzadas:diario:dificil:2026-11-17');
    expect(diario.nivel, Nivel.dificil);
    expect(diario.temas, isEmpty);
  });

  test('semana começa na segunda-feira', () {
    expect(Placar.inicioDaSemana(agora), DateTime(2026, 11, 16));
    expect(
      Placar.inicioDaSemana(DateTime(2026, 11, 16, 0, 1)),
      DateTime(2026, 11, 16),
    );
    expect(
      Placar.inicioDaSemana(DateTime(2026, 11, 22, 23)),
      DateTime(2026, 11, 16),
    );
  });

  test('soma por jogador, ordena e inclui quem não jogou', () {
    final linhas = Placar.calcular(
      perfis: [1, 2, 3],
      registros: [r(1, 30), r(2, 50), r(1, 10)],
      filtro: const FiltroPlacar(),
      agora: agora,
    );
    expect(linhas.map((l) => l.perfilId), [2, 1, 3]);
    expect(linhas.map((l) => l.pontos), [50, 40, 0]);
    expect(linhas[1].desafios, 2);
    expect(linhas.map((l) => l.posicao), [1, 2, 3]);
  });

  test('empate em pontos divide a posição', () {
    final linhas = Placar.calcular(
      perfis: [1, 2],
      registros: [r(1, 20), r(2, 20)],
      filtro: const FiltroPlacar(),
      agora: agora,
    );
    expect(linhas.map((l) => l.posicao), [1, 1]);
  });

  test('filtros: semana, jogo, nível e tema', () {
    final registros = [
      r(1, 10, quando: DateTime(2026, 11, 10)), // semana passada
      r(1, 20, id: 'caca:leve:animais:2', modo: 'caca_palavras'),
      r(1, 40, id: 'cruzadas:medio:frutas:3'),
      r(1, 80, id: 'cruzadas:leve:animais+frutas:4'),
    ];
    int total(FiltroPlacar f) => Placar.calcular(
      perfis: [1],
      registros: registros,
      filtro: f,
      agora: agora,
    ).single.pontos;

    expect(total(const FiltroPlacar(soEstaSemana: false)), 150);
    expect(total(const FiltroPlacar()), 140);
    expect(total(const FiltroPlacar(modo: 'caca_palavras')), 20);
    expect(total(const FiltroPlacar(nivel: Nivel.medio)), 40);
    // Tema: só desafios montados com aquele tema sozinho.
    expect(total(const FiltroPlacar(tema: 'animais')), 20);
  });

  test('registro de jogador apagado é ignorado', () {
    final linhas = Placar.calcular(
      perfis: [1],
      registros: [r(1, 5), r(9, 100)],
      filtro: const FiltroPlacar(),
      agora: agora,
    );
    expect(linhas.single.pontos, 5);
  });
}
