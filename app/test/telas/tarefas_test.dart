import 'dart:isolate';

import 'package:cruzaletra/dominio/nivel.dart';
import 'package:cruzaletra/telas/tela_inicio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio.dart';

/// O botão "Jogar" monta a grade em outro isolate. Se a tarefa levar junto
/// algo que não pode ser enviado (como a tela), o botão não faz nada.
void main() {
  final temas = temasDoDisco();

  test('tarefa das cruzadas roda em outro isolate', () async {
    final d = await Isolate.run(tarefaCruzadas(temas, Nivel.medio, 42));
    expect(d.palavras, isNotEmpty);
  });

  test('tarefa do desafio diário roda em outro isolate', () async {
    final infantis = temas.where((t) => t.infantil).toList();
    final d = await Isolate.run(
      tarefaDiario(infantis, Nivel.leve, DateTime(2026, 11, 16)),
    );
    expect(d.diario, '2026-11-16');
  });
}
