import 'package:cruzaletra/app.dart';
import 'package:cruzaletra/dados/banco.dart';
import 'package:cruzaletra/dominio/tema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre pedindo o primeiro jogador', (tester) async {
    final banco = Banco(NativeDatabase.memory());
    await tester.pumpWidget(
      CruzaLetraApp(banco: banco, temas: RepositorioTemas()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Novo jogador'), findsOneWidget);
    await banco.close();
  });
}
