import 'dart:async';

import 'package:palavras_cruzadas/app.dart';
import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:palavras_cruzadas/dominio/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:palavras_cruzadas/dominio/pontuacao.dart';
import 'package:palavras_cruzadas/telas/tela_desafio_dia.dart';
import 'package:palavras_cruzadas/telas/tela_inicio.dart';
import 'package:palavras_cruzadas/telas/tela_placar.dart';
import 'package:palavras_cruzadas/telas/tela_resultado.dart';

void main() {
  testWidgets('abre pedindo o primeiro jogador', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Novo jogador'), findsOneWidget);
    await banco.close();
  });

  testWidgets('Como jogar abre e passa as páginas', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Como jogar'));
    await tester.pumpAndSettle();
    expect(find.text('Pular'), findsOneWidget);
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Crie seu jogador'), findsOneWidget);
    await banco.close();
  });

  testWidgets('Placar da família fica escondido no 1.0', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await banco.criarPerfil(
      nome: 'Ana',
      anoNascimento: 2015,
      avatar: '🦁',
      nivel: 'leve',
    );
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Placar da família'), findsNothing);
    await banco.close();
  });

  testWidgets('tela do placar abre vazia', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(
      nav.push(MaterialPageRoute<void>(builder: (_) => const TelaPlacar())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.textContaining('Ninguém pontuou'), findsOneWidget);
    await banco.close();
  });

  testWidgets('cartão Caça-palavras abre o jogo já escolhido', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await banco.criarPerfil(
      nome: 'Bia',
      anoNascimento: 2015,
      avatar: '🐶',
      nivel: 'leve',
    );
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Caça-palavras'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final tela = tester.widget<TelaInicio>(find.byType(TelaInicio));
    expect(tela.modoInicial, Modo.caca);
    await banco.close();
  });

  testWidgets('cartão Cruzadas sem jogador abre o cadastro', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cruzadas'));
    await tester.pumpAndSettle();
    expect(find.text('Nome ou apelido'), findsOneWidget);
    await banco.close();
  });

  testWidgets('resultado mostra o botão de compartilhar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaResultado(
          nivel: Nivel.leve,
          palavras: const [],
          pontuacao: Pontuacao.calcular(
            nivel: Nivel.leve,
            letras: 20,
            segundos: 60,
            tempoAlvoSegundos: 100,
            dicasLetra: 0,
            dicasPalavra: 0,
          ),
          segundos: 60,
          textoCompartilhar: 'Palavras Cruzadas',
        ),
      ),
    );
    expect(find.text('Compartilhar resultado'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Outros apps'), findsOneWidget);
  });

  testWidgets('cartão Desafio do dia abre a tela do dia', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await banco.criarPerfil(
      nome: 'Lia',
      anoNascimento: 2016,
      avatar: '🐱',
      nivel: 'leve',
    );
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desafio do dia'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TelaDesafioDia), findsOneWidget);
    await banco.close();
  });
}
