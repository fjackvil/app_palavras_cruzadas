import 'package:cruzaletra/dominio/texto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tira acentos, cedilha, espaços e hífens', () {
    expect(paraGrade('Ação'), 'ACAO');
    expect(paraGrade('LEÃO'), 'LEAO');
    expect(paraGrade('pêssego'), 'PESSEGO');
    expect(paraGrade('Corpo-humano'), 'CORPOHUMANO');
    expect(paraGrade('bossa nova'), 'BOSSANOVA');
    expect(paraGrade('ÔNIBUS'), 'ONIBUS');
  });
}
