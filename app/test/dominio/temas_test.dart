import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio.dart';

const categorias = {
  'Mundo', 'Natureza', 'Comida', 'Cinema e TV', 'Música', 'História', //
  'Ciência', 'Esportes', 'Cultura', 'Dia a dia', 'Língua portuguesa',
  'Atualidades',
};

void main() {
  final temas = temasDoDisco();

  test('ids e nomes de tema não se repetem', () {
    expect(temas.map((t) => t.id).toSet().length, temas.length);
    expect(temas.map((t) => t.nome).toSet().length, temas.length);
  });

  test('há temas grátis e infantis', () {
    expect(temas.where((t) => !t.premium).length, greaterThanOrEqualTo(5));
    expect(temas.where((t) => t.infantil).length, greaterThanOrEqualTo(5));
  });

  for (final tema in temas) {
    test('tema ${tema.nome} está bem formado', () {
      expect(categorias, contains(tema.categoria));
      expect(tema.palavras.length, greaterThanOrEqualTo(40));
      final grafias = tema.palavras.map((p) => p.grade).toList();
      expect(grafias.toSet().length, grafias.length, reason: 'repetidas');
      for (final p in tema.palavras) {
        expect(p.grade.length, inInclusiveRange(3, 13), reason: p.palavra);
        expect(p.dificuldade, inInclusiveRange(1, 4), reason: p.palavra);
        for (final chave in ['leve', 'media', 'dificil']) {
          expect(p.dicas[chave], isNotEmpty, reason: '${p.palavra} $chave');
        }
      }
      // Todo tema serve para os 4 níveis.
      for (final nivel in Nivel.values) {
        expect(tema.disponivelPara(nivel), isTrue, reason: nivel.nome);
      }
    });
  }
}
