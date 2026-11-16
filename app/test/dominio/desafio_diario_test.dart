import 'package:palavras_cruzadas/dominio/desafio_diario.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio.dart';

void main() {
  final temas = temasDoDisco();

  test('mesmo dia e nível dá a mesma grade; outro dia muda', () {
    final dia = DateTime(2026, 11, 16, 9);
    final mesmoDia = DateTime(2026, 11, 16, 22);
    final a = DesafioDiario.gerar(temas, Nivel.medio, dia);
    final b = DesafioDiario.gerar(temas, Nivel.medio, mesmoDia);
    expect(a.paraJson(), b.paraJson());
    expect(a.id, 'cruzadas:diario:medio:2026-11-16');

    final amanha = DesafioDiario.gerar(
      temas,
      Nivel.medio,
      DateTime(2026, 11, 17),
    );
    expect(amanha.paraJson(), isNot(a.paraJson()));
  });

  test('o diário só usa temas infantis', () {
    final ids = DesafioDiario.temas(temas, Nivel.leve).map((t) => t.id);
    final infantis = temas.where((t) => t.infantil).map((t) => t.id);
    expect(ids.every(infantis.contains), isTrue);
  });

  test('dias seguidos contam até hoje ou até ontem', () {
    final hoje = DateTime(2026, 3, 1);
    expect(DesafioDiario.diasSeguidos({}, hoje), 0);
    // Hoje, ontem (fevereiro) e anteontem.
    expect(
      DesafioDiario.diasSeguidos({
        '2026-03-01',
        '2026-02-28',
        '2026-02-27',
      }, hoje),
      3,
    );
    // Ainda não jogou hoje: conta a sequência até ontem.
    expect(DesafioDiario.diasSeguidos({'2026-02-28', '2026-02-27'}, hoje), 2);
    // Buraco quebra a sequência.
    expect(DesafioDiario.diasSeguidos({'2026-03-01', '2026-02-27'}, hoje), 1);
  });
}
