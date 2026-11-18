import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:palavras_cruzadas/dados/sons.dart';

void main() {
  test('o som mais especial ganha', () {
    expect(somDoFim(recorde: true, conquista: true), Som.recorde);
    expect(somDoFim(recorde: false, conquista: true), Som.conquista);
    expect(somDoFim(recorde: false, conquista: false), Som.vitoria);
  });

  test('sons começam ligados e dá para desligar', () async {
    final banco = Banco(NativeDatabase.memory());
    expect(await Sons.ligados(banco), isTrue);
    await Sons.ligar(banco, ligado: false);
    expect(await Sons.ligados(banco), isFalse);
    await banco.close();
  });
}
