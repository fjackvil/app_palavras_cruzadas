import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/jogo_caca.dart';

/// Cores das palavras achadas, em rodízio.
const coresAchadas = [
  Color(0xFF66CC39),
  Color(0xFFE9B320),
  Color(0xFF4FA3E0),
  Color(0xFFF07C7C),
  Color(0xFFB07CE0),
  Color(0xFF3CC4B4),
  Color(0xFFF0A050),
  Color(0xFF9CB83C),
];

Color corDaPalavra(int indice) => coresAchadas[indice % coresAchadas.length];

/// Grade do caça-palavras: arraste o dedo da primeira à última letra (ou
/// toque na primeira e depois na última).
class GradeCaca extends StatefulWidget {
  const GradeCaca({
    super.key,
    required this.jogo,
    this.aoAchar,
    this.somenteLeitura = false,
  });

  final JogoCaca jogo;

  /// Chamado com o índice da palavra achada.
  final ValueChanged<int>? aoAchar;
  final bool somenteLeitura;

  @override
  State<GradeCaca> createState() => _GradeCacaState();
}

class _GradeCacaState extends State<GradeCaca> {
  (int, int)? _inicio;
  (int, int)? _fim;

  JogoCaca get _jogo => widget.jogo;

  (int, int)? _casaEm(Offset p, double lado) {
    final n = _jogo.desafio.tamanho;
    final l = (p.dy / lado).floor();
    final c = (p.dx / lado).floor();
    if (l < 0 || c < 0 || l >= n || c >= n) return null;
    return (l, c);
  }

  /// Leva o fim do arrasto para a linha reta mais próxima (horizontal,
  /// vertical ou diagonal), para o dedo não precisar ser perfeito.
  (int, int) _ajustar((int, int) inicio, (int, int) fim) {
    final n = _jogo.desafio.tamanho;
    final dl = fim.$1 - inicio.$1;
    final dc = fim.$2 - inicio.$2;
    final adl = dl.abs();
    final adc = dc.abs();
    if (adl == 0 || adc == 0 || adl == adc) return fim;
    if (adl > 2 * adc) return (fim.$1, inicio.$2);
    if (adc > 2 * adl) return (inicio.$1, fim.$2);
    var k = adl < adc ? adl : adc;
    // Diagonal: anda k passos sem sair da grade.
    while (k > 0) {
      final l = inicio.$1 + dl.sign * k;
      final c = inicio.$2 + dc.sign * k;
      if (l >= 0 && c >= 0 && l < n && c < n) return (l, c);
      k--;
    }
    return inicio;
  }

  void _terminar() {
    final inicio = _inicio;
    final fim = _fim;
    setState(() {
      _inicio = null;
      _fim = null;
    });
    if (inicio == null || fim == null || inicio == fim) return;
    final achada = _jogo.tentar(inicio.$1, inicio.$2, fim.$1, fim.$2);
    if (achada != null) widget.aoAchar?.call(achada);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, box) {
          final lado = box.maxWidth / _jogo.desafio.tamanho;
          final pintura = CustomPaint(
            size: Size.square(box.maxWidth),
            painter: _PinturaCaca(
              jogo: _jogo,
              selecao: _inicio == null || _fim == null
                  ? null
                  : (_inicio!, _fim!),
            ),
          );
          if (widget.somenteLeitura) return pintura;
          return GestureDetector(
            onPanStart: (d) {
              _jogo.comecar();
              final casa = _casaEm(d.localPosition, lado);
              setState(() {
                _inicio = casa;
                _fim = casa;
              });
            },
            onPanUpdate: (d) {
              final casa = _casaEm(d.localPosition, lado);
              if (casa == null || _inicio == null) return;
              setState(() => _fim = _ajustar(_inicio!, casa));
            },
            onPanEnd: (_) => _terminar(),
            onPanCancel: () => setState(() {
              _inicio = null;
              _fim = null;
            }),
            onTapUp: (d) {
              final casa = _casaEm(d.localPosition, lado);
              if (casa == null) return;
              final inicio = _jogo.inicioToque;
              final alvo = inicio == null ? casa : _ajustar(inicio, casa);
              final achada = _jogo.tocar(alvo.$1, alvo.$2);
              if (achada != null) widget.aoAchar?.call(achada);
            },
            child: pintura,
          );
        },
      ),
    );
  }
}

class _PinturaCaca extends CustomPainter {
  _PinturaCaca({required this.jogo, required this.selecao})
    : super(repaint: jogo);

  final JogoCaca jogo;
  final ((int, int), (int, int))? selecao;

  @override
  void paint(Canvas canvas, Size size) {
    final d = jogo.desafio;
    final n = d.tamanho;
    final lado = size.width / n;
    Offset centro((int, int) c) =>
        Offset((c.$2 + 0.5) * lado, (c.$1 + 0.5) * lado);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      Paint()..color = Colors.white,
    );

    void capsula((int, int) a, (int, int) b, Color cor) {
      canvas.drawLine(
        centro(a),
        centro(b),
        Paint()
          ..color = cor
          ..strokeWidth = lado * 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Palavras achadas, cada uma com sua cor.
    for (final i in jogo.encontradas) {
      final p = d.palavras[i];
      capsula(
        p.casa(0),
        p.casa(p.tamanho - 1),
        corDaPalavra(i).withValues(alpha: 0.55),
      );
    }

    // Dica: círculo na primeira letra.
    for (final i in jogo.comDica) {
      if (jogo.encontradas.contains(i)) continue;
      canvas.drawCircle(
        centro(d.palavras[i].casa(0)),
        lado * 0.42,
        Paint()
          ..color = CoresMarca.vermelho
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // Seleção em andamento (arrasto ou primeiro toque).
    final sel = selecao;
    if (sel != null) {
      capsula(sel.$1, sel.$2, CoresMarca.amarelo.withValues(alpha: 0.6));
    } else if (jogo.inicioToque != null) {
      capsula(
        jogo.inicioToque!,
        jogo.inicioToque!,
        CoresMarca.amarelo.withValues(alpha: 0.6),
      );
    }

    final estilo = TextStyle(
      fontSize: lado * 0.55,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );
    for (var l = 0; l < n; l++) {
      for (var c = 0; c < n; c++) {
        final tp = TextPainter(
          text: TextSpan(text: d.letra(l, c), style: estilo),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, centro((l, c)) - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_PinturaCaca old) => old.selecao != selecao;
}

/// Lista das palavras (ou só das dicas, no Super difícil), riscando as
/// achadas.
class ListaCaca extends StatelessWidget {
  const ListaCaca({super.key, required this.jogo});

  final JogoCaca jogo;

  @override
  Widget build(BuildContext context) {
    final d = jogo.desafio;
    final texto = Theme.of(context).textTheme;
    if (d.regras.mostrarPalavras) {
      return Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < d.palavras.length; i++)
            Chip(
              backgroundColor: jogo.encontradas.contains(i)
                  ? corDaPalavra(i).withValues(alpha: 0.35)
                  : null,
              label: Text(
                d.palavras[i].escrita,
                style:
                    (d.nivel.index == 0 ? texto.titleMedium : texto.bodyLarge)
                        ?.copyWith(
                          decoration: jogo.encontradas.contains(i)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < d.palavras.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              jogo.encontradas.contains(i)
                  ? '✓ ${d.palavras[i].escrita} — ${d.palavras[i].dica}'
                  : '• ${d.palavras[i].dica} (${d.palavras[i].tamanho} letras)',
              style: texto.bodyMedium?.copyWith(
                color: jogo.encontradas.contains(i) ? Colors.black54 : null,
                decoration: jogo.encontradas.contains(i)
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
