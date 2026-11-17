import 'package:palavras_cruzadas/app.dart';
import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:palavras_cruzadas/dominio/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('Placar da família aparece com jogador cadastrado', (
    tester,
  ) async {
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
    await tester.tap(find.text('Placar da família'));
    await tester.pumpAndSettle();
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.textContaining('Ninguém pontuou'), findsOneWidget);
    await banco.close();
  });
}
