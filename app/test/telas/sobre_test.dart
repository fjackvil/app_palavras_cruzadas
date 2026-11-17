import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/telas/tela_sobre.dart';

void main() {
  test('versão da tela Sobre é a mesma do pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versao = RegExp(
      r'^version: ([0-9.]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(versaoApp, versao);
  });

  test('a política é lida em blocos: título, seções, itens e parágrafos', () {
    final md = File(arquivoPolitica).readAsStringSync();
    final blocos = blocosMarkdown(md);
    expect(blocos.first.tipo, TipoBloco.titulo);
    final secoes = blocos
        .where((b) => b.tipo == TipoBloco.secao)
        .map((b) => b.texto);
    expect(secoes, containsAll(['Resumo', 'Crianças', 'Contato']));
    expect(blocos.where((b) => b.tipo == TipoBloco.item), isNotEmpty);
  });

  test('a política não promete o que o app não cumpre', () {
    final md = File(arquivoPolitica).readAsStringSync();
    final manifesto = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    // A política diz que o app não pede localização, câmera etc., e que a
    // internet vem só do sistema de compras do Google Play (ela é posta pela
    // biblioteca de compras, não pelo manifesto do app).
    expect(md, contains('não pede permissão de localização'));
    expect(md, contains('sistema de compras do Google Play'));
    for (final p in [
      'INTERNET',
      'LOCATION',
      'CAMERA',
      'CONTACTS',
      'RECORD_AUDIO',
    ]) {
      expect(manifesto, isNot(contains('permission.$p')), reason: p);
    }
  });

  test('a política tem um e-mail de contato de verdade', () {
    final md = File(arquivoPolitica).readAsStringSync();
    expect(md, isNot(contains('[E-MAIL')));
    expect(md, contains('vileladigit@gmail.com'));
  });

  test('termos de uso existem, com Premium, reembolso e contato', () {
    final md = File(arquivoTermos).readAsStringSync();
    final secoes = blocosMarkdown(md)
        .where((b) => b.tipo == TipoBloco.secao)
        .map((b) => b.texto);
    expect(secoes, containsAll(['Plano grátis e Premium', 'Contato']));
    expect(md, contains('Código de Defesa do Consumidor'));
    expect(md, contains('vileladigit@gmail.com'));
  });
}
