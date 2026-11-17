import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/dominio/compartilhar.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';

void main() {
  test('texto do desafio do dia', () {
    final t = textoResultado(
      caca: false,
      nivel: Nivel.leve,
      diario: '2026-11-17',
      pontos: 42,
      segundos: 192,
      dicas: 0,
      palavras: 6,
    );
    expect(t, contains('Desafio do dia 17/11 · Cruzadas · Leve'));
    expect(t, contains('42 pontos em ⏱ 3min12s'));
    expect(t, contains('sem nenhuma dica'));
    expect(t, contains('mesma grade'));
  });

  test('texto de caça-palavras livre, com dicas', () {
    final t = textoResultado(
      caca: true,
      nivel: Nivel.superDificil,
      diario: null,
      pontos: 300,
      segundos: 45,
      dicas: 2,
      palavras: 12,
    );
    expect(t, contains('Caça-palavras · Super difícil'));
    expect(t, contains('45s'));
    expect(t, contains('com 2 dicas'));
    expect(t, isNot(contains('mesma grade')));
  });

  test('texto termina com o link para instalar; links do WhatsApp', () {
    final t = textoResultado(
      caca: false,
      nivel: Nivel.medio,
      diario: null,
      pontos: 10,
      segundos: 10,
      dicas: 0,
      palavras: 3,
    );
    expect(t.trim().split('\n').last, endsWith(linkLoja));
    expect(linkLoja, contains('com.vileladigit.palavrascruzadas'));
    final wa = linkWhatsApp('Oi ⭐ 10');
    expect(wa.host, 'wa.me');
    expect(wa.queryParameters['text'], 'Oi ⭐ 10');
    expect(linkAppWhatsApp('x').scheme, 'whatsapp');
  });
}
