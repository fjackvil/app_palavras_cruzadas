import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:palavras_cruzadas/dominio/porta_pais.dart';
import 'package:palavras_cruzadas/widgets/porta_pais.dart';

void main() {
  testWidgets('porta dos pais: errado não passa, certo passa', (t) async {
    bool? resultado;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado = await showDialog<bool>(
                context: context,
                builder: (_) =>
                    const DialogoPortaPais(pergunta: PerguntaPais(6, 9)),
              );
            },
            child: const Text('comprar'),
          ),
        ),
      ),
    );
    await t.tap(find.text('comprar'));
    await t.pumpAndSettle();
    expect(find.text('Quanto é 6 × 9?'), findsOneWidget);

    await t.enterText(find.byType(TextField), '45');
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.text('Resposta errada. Tente de novo.'), findsOneWidget);
    expect(resultado, isNull);

    await t.enterText(find.byType(TextField), '54');
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(resultado, isTrue);
    expect(find.text('Quanto é 6 × 9?'), findsNothing);
  });
}
