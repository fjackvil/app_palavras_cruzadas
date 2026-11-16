import 'package:material_ui/material_ui.dart';

/// Teclado próprio do app. Não tem acentos: a grade usa letras sem acento.
class Teclado extends StatelessWidget {
  const Teclado({
    super.key,
    required this.aoDigitar,
    required this.aoApagar,
    this.grande = false,
  });

  final ValueChanged<String> aoDigitar;
  final VoidCallback aoApagar;

  /// Teclas maiores (nível Leve).
  final bool grande;

  static const _linhas = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  @override
  Widget build(BuildContext context) {
    final altura = grande ? 56.0 : 46.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < _linhas.length; r++)
            Row(
              children: [
                if (r == 1) const Spacer(),
                for (final letra in _linhas[r].split(''))
                  Expanded(
                    flex: 2,
                    child: _Tecla(
                      altura: altura,
                      rotulo: letra,
                      grande: grande,
                      aoTocar: () => aoDigitar(letra),
                    ),
                  ),
                if (r == 1) const Spacer(),
                if (r == 2)
                  Expanded(
                    flex: 3,
                    child: _Tecla(
                      altura: altura,
                      icone: Icons.backspace_outlined,
                      grande: grande,
                      semantica: 'Apagar',
                      aoTocar: aoApagar,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla({
    required this.altura,
    required this.aoTocar,
    required this.grande,
    this.rotulo,
    this.icone,
    this.semantica,
  });

  final double altura;
  final VoidCallback aoTocar;
  final bool grande;
  final String? rotulo;
  final IconData? icone;
  final String? semantica;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: aoTocar,
          child: SizedBox(
            height: altura,
            child: Center(
              child: rotulo != null
                  ? Text(
                      rotulo!,
                      style: TextStyle(
                        fontSize: grande ? 24 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Icon(icone, semanticLabel: semantica),
            ),
          ),
        ),
      ),
    );
  }
}
