import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:palavras_cruzadas/dados/premium.dart';

/// O código de verdade fica só em `codigo-revisor.txt` (fora do Git). Sem
/// ele, o teste do código certo é pulado.
String? codigoLocal() {
  final f = File('codigo-revisor.txt');
  if (!f.existsSync()) return null;
  return f
      .readAsLinesSync()
      .map((l) => l.trim())
      .lastWhere((l) => l.isNotEmpty);
}

void main() {
  late Banco banco;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    banco = Banco(NativeDatabase.memory());
  });
  tearDown(() => banco.close());

  test('código errado não libera o Premium', () async {
    final p = ServicoPremium(banco, usarLoja: false);
    await p.iniciar();
    for (final c in ['', 'premium', 'ABCDEFGHJK', '1234567890']) {
      expect(await p.usarCodigoRevisor(c), isFalse, reason: c);
    }
    expect(p.premium, isFalse);
  });

  test('código certo libera o Premium e continua depois de reabrir', () async {
    final codigo = codigoLocal()!;
    final p = ServicoPremium(banco, usarLoja: false);
    await p.iniciar();
    // Aceita minúsculas, espaços e hífen.
    final digitado =
        '${codigo.substring(0, 4).toLowerCase()}- ${codigo.substring(4)}';
    expect(await p.usarCodigoRevisor(digitado), isTrue);
    expect(p.premium, isTrue);

    final reaberto = ServicoPremium(banco, usarLoja: false);
    await reaberto.iniciar();
    expect(reaberto.premium, isTrue);
  }, skip: codigoLocal() == null ? 'sem codigo-revisor.txt' : false);
}
