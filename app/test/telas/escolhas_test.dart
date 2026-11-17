import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/widgets/escolhas_inicio.dart';

void main() {
  test('resumo da categoria mostra o que é grátis e o que é Premium', () {
    expect(
      resumoCategoria(total: 7, escolhidos: 0, travados: 6),
      '1 grátis · 6 🔒',
    );
    expect(resumoCategoria(total: 5, escolhidos: 0, travados: 5), '🔒 Premium');
    expect(resumoCategoria(total: 7, escolhidos: 0, travados: 0), '7 temas');
    expect(resumoCategoria(total: 7, escolhidos: 1, travados: 6), '1 de 7 ✓');
  });
}
