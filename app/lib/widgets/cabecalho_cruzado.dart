import 'package:material_ui/material_ui.dart';

import '../app.dart';

/// Cabeçalho da tela de abertura: o nome do app ao lado de um pequeno
/// caça-palavras, com as palavras achadas sendo marcadas ao abrir.
class CabecalhoCruzado extends StatefulWidget {
  const CabecalhoCruzado({super.key, this.subtitulo});

  final String? subtitulo;

  @override
  State<CabecalhoCruzado> createState() => _CabecalhoCruzadoState();
}

class _CabecalhoCruzadoState extends State<CabecalhoCruzado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              SizedBox(
                width: 136,
                height: 136,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) =>
                      CustomPaint(painter: _MiniCaca(progresso: _anim.value)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Palavras\nCruzadas e\nCaça-palavras',
                      style: texto.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    if (widget.subtitulo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitulo!,
                        style: texto.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um caça-palavras 6×6 de enfeite, com SOL, LUA e MAR escondidas. As
/// marcações aparecem uma depois da outra conforme [progresso] vai de 0 a 1.
class _MiniCaca extends CustomPainter {
  _MiniCaca({required this.progresso});

  final double progresso;

  static const _letras = [
    'SOLBTA',
    'ERUCAM',
    'LUAPIA',
    'MEDOFR',
    'GATOXV',
    'NIRPLE',
  ];

  /// (linha, coluna) do início e do fim de cada palavra, e a cor.
  static const _palavras = [
    ((0, 0), (0, 2), CoresMarca.amarelo), // SOL →
    ((2, 0), (2, 2), Color(0xFF4FA3E0)), // LUA →
    ((1, 5), (3, 5), Color(0xFFF07C7C)), // MAR ↓
    ((4, 0), (4, 3), Color(0xFFB07CE0)), // GATO →
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final n = _letras.length;
    final lado = size.width / n;
    Offset centro((int, int) c) =>
        Offset((c.$2 + 0.5) * lado, (c.$1 + 0.5) * lado);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      Paint()..color = Colors.white,
    );

    for (var i = 0; i < _palavras.length; i++) {
      final (a, b, cor) = _palavras[i];
      // Cada palavra é "riscada" num trecho da animação.
      final t = ((progresso - 0.15 - i * 0.18) / 0.25).clamp(0.0, 1.0);
      if (t == 0) continue;
      final inicio = centro(a);
      final fim = Offset.lerp(inicio, centro(b), Curves.easeOut.transform(t))!;
      canvas.drawLine(
        inicio,
        fim,
        Paint()
          ..color = cor.withValues(alpha: 0.7)
          ..strokeWidth = lado * 0.78
          ..strokeCap = StrokeCap.round,
      );
    }

    final estilo = TextStyle(
      fontSize: lado * 0.58,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1B2A1B),
    );
    for (var l = 0; l < n; l++) {
      for (var c = 0; c < n; c++) {
        final tp = TextPainter(
          text: TextSpan(text: _letras[l][c], style: estilo),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, centro((l, c)) - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_MiniCaca old) => old.progresso != progresso;
}
