import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/app.dart';
import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:palavras_cruzadas/dominio/tema.dart';
import 'package:material_ui/material_ui.dart';
import 'package:palavras_cruzadas/telas/tela_sobre.dart';

void main() {
  testWidgets('7 toques na versão abrem o campo do código', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await tester.pumpWidget(
      PalavrasCruzadasApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sobre e privacidade'));
    await tester.pumpAndSettle();
    for (var i = 0; i < VersaoComCodigo.toquesParaAbrir; i++) {
      await tester.tap(find.textContaining('Versão'));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(find.text('Código de acesso'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ERRADO123');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Código inválido.'), findsOneWidget);
    await banco.close();
  });
}
