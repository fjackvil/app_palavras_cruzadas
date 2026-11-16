import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app.dart';

/// Cabeçalho da tela de abertura: PALAVRAS e CRUZADAS se cruzando, com as
/// casas caindo uma a uma ao abrir o app.
class CabecalhoCruzado extends StatefulWidget {
  const CabecalhoCruzado({super.key, this.subtitulo});

  final String? subtitulo;

  @override
  State<CabecalhoCruzado> createState() => _CabecalhoCruzadoState();
}

/// Uma casa do desenho: linha, coluna, letra e ordem em que aparece.
typedef _Casa = ({int linha, int coluna, String letra, int ordem});

class _CabecalhoCruzadoState extends State<CabecalhoCruzado>
    with SingleTickerProviderStateMixin {
  static const _horizontal = 'PALAVRAS';
  static const _vertical = 'CRUZADAS';

  /// PALAVRAS na linha 4; CRUZADAS na coluna 3. Elas se cruzam no A
  /// (4ª letra de PALAVRAS e 5ª de CRUZADAS).
  static const _linhaH = 4;
  static const _colunaV = 3;
  static const _lado = 8;

  late final List<_Casa> _casas = _montar();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  static List<_Casa> _montar() {
    final casas = <_Casa>[];
    var ordem = 0;
    for (var c = 0; c < _horizontal.length; c++) {
      casas.add((
        linha: _linhaH,
        coluna: c,
        letra: _horizontal[c],
        ordem: ordem++,
      ));
    }
    for (var l = 0; l < _vertical.length; l++) {
      if (l == _linhaH) continue; // o A do cruzamento já entrou
      casas.add((
        linha: l,
        coluna: _colunaV,
        letra: _vertical[l],
        ordem: ordem++,
      ));
    }
    return casas;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CoresMarca.verde, CoresMarca.verdeClaro],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, box) {
                  final casa = min(box.maxWidth / (_lado + 0.5), 34.0);
                  return SizedBox(
                    width: casa * _lado,
                    height: casa * _lado,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) => Stack(
                        children: [for (final c in _casas) _casa(c, casa)],
                      ),
                    ),
                  );
                },
              ),
              if (widget.subtitulo != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.subtitulo!,
                  textAlign: TextAlign.center,
                  style: texto.titleMedium?.copyWith(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _casa(_Casa c, double lado) {
    final total = _casas.length;
    // Cada casa cai num pedaço do tempo, uma depois da outra.
    final inicio = c.ordem / (total + 4);
    final fim = (c.ordem + 5) / (total + 4);
    final t = Curves.easeOutBack.transform(
      ((_anim.value - inicio) / (fim - inicio)).clamp(0.0, 1.0),
    );
    final cruzamento = c.linha == _linhaH && c.coluna == _colunaV;
    return Positioned(
      left: c.coluna * lado,
      top: c.linha * lado,
      width: lado,
      height: lado,
      child: Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * -lado),
          child: Transform.scale(
            scale: 0.6 + 0.4 * t,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: cruzamento ? CoresMarca.amarelo : Colors.white,
                borderRadius: BorderRadius.circular(lado * 0.18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                c.letra,
                style: TextStyle(
                  fontSize: lado * 0.55,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2A1B),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
