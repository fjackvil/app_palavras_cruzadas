import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/porta_pais.dart';

void main() {
  test('a conta sempre tem resultado de dois dígitos', () {
    final r = Random(1);
    for (var i = 0; i < 200; i++) {
      final p = PerguntaPais.sortear(r);
      expect(p.resposta, inInclusiveRange(36, 81));
    }
  });

  test('só aceita a resposta certa', () {
    const p = PerguntaPais(7, 8);
    expect(p.texto, 'Quanto é 7 × 8?');
    expect(p.confere('56'), isTrue);
    expect(p.confere(' 56 '), isTrue);
    expect(p.confere('54'), isFalse);
    expect(p.confere(''), isFalse);
    expect(p.confere('abc'), isFalse);
  });
}
