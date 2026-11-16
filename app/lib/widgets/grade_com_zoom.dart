import 'package:material_ui/material_ui.dart';

import '../dominio/jogo_cruzadas.dart';
import 'grade_cruzadas.dart';

/// A grade com zoom de dois dedos nas grades grandes (13×13 e 15×15), em
/// que as casas ficam pequenas no celular.
class GradeComZoom extends StatelessWidget {
  const GradeComZoom({super.key, required this.jogo});

  /// A partir deste tamanho a grade pode ser aproximada.
  static const tamanhoComZoom = 13;

  final JogoCruzadas jogo;

  @override
  Widget build(BuildContext context) {
    final grade = Center(child: GradeCruzadas(jogo: jogo));
    if (jogo.desafio.tamanho < tamanhoComZoom) return grade;
    return Column(
      children: [
        Expanded(child: InteractiveViewer(maxScale: 3, child: grade)),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Use dois dedos para aproximar a grade.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
