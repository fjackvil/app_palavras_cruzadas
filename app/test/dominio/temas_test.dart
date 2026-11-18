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
      // Todo tema serve do Leve ao Super (o Pequenos só usa temas com
      // desenhos; tem teste próprio abaixo).
      for (final nivel in Nivel.values.where((n) => !n.soComDesenho)) {
        expect(tema.disponivelPara(nivel), isTrue, reason: nivel.nome);
      }
    });
  }

  test('Pequenos: temas com desenhos, palavras curtas e fáceis', () {
    final pequenos = temas.where((t) => t.disponivelPara(Nivel.pequenos));
    expect(pequenos.length, greaterThanOrEqualTo(9));
    for (final t in pequenos) {
      expect(t.infantil, isTrue, reason: t.nome);
      for (final p in t.palavrasPara(Nivel.pequenos)) {
        expect(p.emoji, isNotEmpty, reason: p.palavra);
        expect(p.dicaPara(Nivel.pequenos), p.emoji);
        expect(p.grade.length, inInclusiveRange(3, 6), reason: p.palavra);
        expect(p.dificuldade, 1, reason: p.palavra);
      }
    }
    // Todo desenho está numa palavra que o Pequenos consegue usar.
    for (final t in temas) {
      for (final p in t.palavras.where((p) => p.emoji != null)) {
        expect(
          t.palavrasPara(Nivel.pequenos),
          contains(p),
          reason: '${t.nome}: ${p.palavra}',
        );
      }
    }
  });

  test('idade sugere o nível', () {
    expect(Nivel.sugeridoParaIdade(4), Nivel.pequenos);
    expect(Nivel.sugeridoParaIdade(5), Nivel.pequenos);
    expect(Nivel.sugeridoParaIdade(6), Nivel.leve);
  });
}
