import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/placar.dart';
import 'package:palavras_cruzadas/dominio/recordes.dart';

RegistroPlacar r(
  int id,
  int pontos,
  int segundos, {
  String desafioId = 'cruzadas:leve:animais:1',
  String modo = 'cruzadas',
}) => RegistroPlacar.doDesafio(
  perfilId: 1,
  modo: modo,
  desafioId: desafioId,
  pontos: pontos,
  quando: DateTime(2026, 11, 17),
  segundos: segundos,
  partidaId: id,
);

void main() {
  test('recordes por jogo e nível, e por tema jogado sozinho', () {
    final rec = Recordes.de([
      r(1, 30, 200),
      r(2, 45, 260),
      r(3, 80, 400, desafioId: 'cruzadas:medio:frutas:2'),
      r(
        4,
        20,
        90,
        desafioId: 'caca:leve:animais+frutas:3',
        modo: 'caca_palavras',
      ),
    ]);
    expect(rec.desafios, 4);
    expect(rec.pontos, 175);
    final leve = rec.porNivel.firstWhere(
      (n) => n.modo == 'cruzadas' && n.nivel == Nivel.leve,
    );
    expect(leve.desafios, 2);
    expect(leve.maiorPontuacao, 45);
    expect(leve.melhorTempo, 200);
    expect(rec.porNivel, hasLength(3));
    // Misturado (2 temas) não entra nos recordes por tema.
    expect(rec.porTema.map((t) => t.tema), ['frutas', 'animais']);
    expect(rec.porTema.first.maiorPontuacao, 80);
  });

  test('novo recorde: pontos e tempo, só contra o mesmo jogo e nível', () {
    final anteriores = [r(1, 30, 200), r(2, 45, 260)];
    expect(Recordes.batidos(r(3, 50, 150), anteriores), [
      'Maior pontuação',
      'Melhor tempo',
    ]);
    expect(Recordes.batidos(r(3, 40, 210), anteriores), isEmpty);
    // O primeiro desafio de um nível não é recorde.
    expect(
      Recordes.batidos(
        r(3, 99, 10, desafioId: 'cruzadas:dificil:x:1'),
        anteriores,
      ),
      isEmpty,
    );
    // A própria partida não conta como anterior.
    expect(Recordes.batidos(r(3, 50, 150), [...anteriores, r(3, 50, 150)]), [
      'Maior pontuação',
      'Melhor tempo',
    ]);
  });
}
