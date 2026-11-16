import 'package:cruzaletra/dominio/nivel.dart';
import 'package:cruzaletra/dominio/subir_nivel.dart';
import 'package:flutter_test/flutter_test.dart';

ResumoPartida r({
  Nivel nivel = Nivel.leve,
  bool concluida = true,
  int dicas = 0,
  int segundos = 50,
}) => ResumoPartida(
  nivel: nivel,
  concluida: concluida,
  dicas: dicas,
  segundos: segundos,
  tempoAlvoSegundos: 100,
);

void main() {
  test('3 seguidas rápidas e sem dica oferecem o próximo nível', () {
    expect(SubirNivel.oferta([r(), r(), r()], Nivel.leve), Nivel.medio);
  });

  test('menos de 3 não oferece', () {
    expect(SubirNivel.oferta([r(), r()], Nivel.leve), isNull);
    expect(SubirNivel.oferta([], Nivel.leve), isNull);
  });

  test('dica, demora ou resposta vista quebram a sequência', () {
    expect(SubirNivel.oferta([r(), r(), r(dicas: 1)], Nivel.leve), isNull);
    expect(SubirNivel.oferta([r(), r(segundos: 101), r()], Nivel.leve), isNull);
    expect(
      SubirNivel.oferta([r(), r(), r(concluida: false), r()], Nivel.leve),
      isNull,
    );
  });

  test('partidas de outro nível não contam', () {
    final lista = [r(), r(), r(nivel: Nivel.medio), r()];
    expect(SubirNivel.oferta(lista, Nivel.leve), isNull);
  });

  test('se recusar, pergunta de novo só depois de mais 3', () {
    final quatro = List.generate(4, (_) => r());
    final seis = List.generate(6, (_) => r());
    expect(SubirNivel.oferta(quatro, Nivel.leve), isNull);
    expect(SubirNivel.oferta(seis, Nivel.leve), Nivel.medio);
  });

  test('não oferece no Super difícil nem se o perfil já mudou de nível', () {
    final sup = List.generate(3, (_) => r(nivel: Nivel.superDificil));
    expect(SubirNivel.oferta(sup, Nivel.superDificil), isNull);
    expect(SubirNivel.oferta([r(), r(), r()], Nivel.medio), isNull);
  });
}
