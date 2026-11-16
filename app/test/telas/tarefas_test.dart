import 'dart:isolate';

import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/telas/tela_inicio.dart';
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

  test('tarefas do caça-palavras rodam em outro isolate', () async {
    final livre = await Isolate.run(tarefaCaca(temas, Nivel.dificil, 9));
    expect(livre.palavras, hasLength(10));
    final diario = await Isolate.run(
      tarefaDiarioCaca(temas, Nivel.leve, DateTime(2026, 11, 16)),
    );
    expect(diario.id, 'caca:diario:leve:2026-11-16');
  });
}
