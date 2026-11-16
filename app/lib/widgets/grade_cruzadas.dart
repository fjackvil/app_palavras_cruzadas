import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/jogo_cruzadas.dart';

/// Desenha a grade: casas pretas, números, letras e a palavra selecionada.
class GradeCruzadas extends StatelessWidget {
  const GradeCruzadas({super.key, required this.jogo});

  final JogoCruzadas jogo;

  @override
  Widget build(BuildContext context) {
    final desafio = jogo.desafio;
    final n = desafio.tamanho;
    final cores = Theme.of(context).colorScheme;
    final atual = jogo.palavraAtual;
    final casasAtuais = atual?.casas.toSet() ?? const <(int, int)>{};

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, box) {
          final lado = box.maxWidth / n;
          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              children: [
                for (var l = 0; l < n; l++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var c = 0; c < n; c++)
                          Expanded(
                            child: _casa(
                              context,
                              l,
                              c,
                              lado,
                              cores,
                              casasAtuais.contains((l, c)),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _casa(
    BuildContext context,
    int l,
    int c,
    double lado,
    ColorScheme cores,
    bool naPalavra,
  ) {
    final desafio = jogo.desafio;
    if (desafio.ehBloqueada(l, c)) {
      return const ColoredBox(color: Colors.black);
    }
    final i = desafio.indice(l, c);
    final selecionada = l == jogo.linha && c == jogo.coluna;
    final numero = desafio.numeroDaCasa(l, c);
    final letra = jogo.respostas[i];

    final fundo = selecionada
        ? CoresMarca.amarelo
        : naPalavra
        ? CoresMarca.verdeClaro.withValues(alpha: 0.35)
        : Colors.white;
    final corLetra = jogo.erradas.contains(i)
        ? CoresMarca.vermelho
        : jogo.reveladas.contains(i)
        ? Colors.blue.shade800
        : Colors.black;

    return GestureDetector(
      onTap: () => jogo.tocar(l, c),
      child: Container(
        margin: const EdgeInsets.all(0.5),
        color: fundo,
        child: Stack(
          children: [
            if (numero != null)
              Positioned(
                left: 2,
                top: 1,
                child: Text(
                  '$numero',
                  style: TextStyle(
                    fontSize: lado * 0.24,
                    color: Colors.black87,
                  ),
                ),
              ),
            Center(
              child: Text(
                letra,
                style: TextStyle(
                  fontSize: lado * 0.55,
                  fontWeight: jogo.fixas.contains(i)
                      ? FontWeight.w400
                      : FontWeight.w700,
                  color: corLetra,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
