import 'package:material_ui/material_ui.dart';

import '../dominio/jogo_caca.dart';
import '../widgets/grade_caca.dart';

/// "Ver resposta" do caça-palavras: todas as palavras marcadas na grade.
/// O desafio já foi encerrado sem pontos.
class TelaRespostaCaca extends StatelessWidget {
  const TelaRespostaCaca({super.key, required this.jogo});

  /// Jogo com [JogoCaca.revelarTudo] já aplicado.
  final JogoCaca jogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resposta')),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Todas as palavras estão marcadas. Este desafio foi '
                'encerrado sem pontos.',
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: GradeCaca(jogo: jogo, somenteLeitura: true),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  for (final p in jogo.desafio.palavras)
                    ListTile(
                      dense: true,
                      title: Text(p.escrita),
                      subtitle: Text(p.dica),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
