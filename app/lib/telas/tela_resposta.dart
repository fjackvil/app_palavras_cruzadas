import 'package:material_ui/material_ui.dart';

import '../dominio/jogo_cruzadas.dart';
import '../widgets/grade_com_zoom.dart';

/// "Ver resposta": a grade completa, com o que faltava em azul, e a lista
/// de palavras. O desafio já foi encerrado sem pontos.
class TelaResposta extends StatelessWidget {
  const TelaResposta({super.key, required this.jogo});

  /// Jogo com [JogoCruzadas.revelarTudo] já aplicado.
  final JogoCruzadas jogo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final desafio = jogo.desafio;
    return Scaffold(
      appBar: AppBar(title: const Text('Resposta')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Em azul, as letras que faltavam. Este desafio foi encerrado '
                'sem pontos.',
                style: texto.bodyMedium,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListenableBuilder(
                  listenable: jogo,
                  builder: (context, _) => GradeComZoom(jogo: jogo),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  for (final p in desafio.palavras)
                    ListTile(
                      dense: true,
                      leading: Text('${p.numero} ${p.horizontal ? '→' : '↓'}'),
                      title: Text(p.escrita),
                      subtitle: Text(p.dica),
                      onTap: () => jogo.selecionarPalavra(p),
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
