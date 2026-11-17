import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/telas/tela_desafio_dia.dart';

void main() {
  test('data por extenso em português', () {
    expect(
      dataPorExtenso(DateTime(2026, 11, 17)),
      'Terça-feira, 17 de novembro',
    );
    expect(dataPorExtenso(DateTime(2026, 3, 1)), 'Domingo, 1 de março');
  });
}
