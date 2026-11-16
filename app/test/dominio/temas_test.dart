import 'package:flutter_test/flutter_test.dart';

import '../apoio.dart';

void main() {
  final temas = temasDoDisco();

  test('a fase 1 tem 5 temas infantis', () {
    expect(temas, hasLength(5));
    expect(temas.every((t) => t.infantil), isTrue);
  });

  for (final tema in temas) {
    test('tema ${tema.nome} está bem formado', () {
      expect(tema.palavras.length, greaterThanOrEqualTo(25));
      final grafias = tema.palavras.map((p) => p.grade).toList();
      expect(grafias.toSet().length, grafias.length, reason: 'repetidas');
      for (final p in tema.palavras) {
        expect(p.grade.length, greaterThanOrEqualTo(3), reason: p.palavra);
        expect(p.dificuldade, inInclusiveRange(1, 4), reason: p.palavra);
        expect(p.dicas['leve'], isNotEmpty, reason: p.palavra);
        expect(p.dicas['media'], isNotEmpty, reason: p.palavra);
        // A dica não pode entregar a resposta.
        expect(
          p.dicas.values.any(
            (d) => d.toUpperCase().contains(p.palavra.toUpperCase()),
          ),
          isFalse,
          reason: p.palavra,
        );
      }
    });
  }
}
