import 'package:material_ui/material_ui.dart';

import '../app.dart';

/// Desenho pequeno de palavras cruzadas: SOL na horizontal cruzando COR na
/// vertical, com casas pretas, igual ao ícone do app.
class IconeCruzadas extends StatelessWidget {
  const IconeCruzadas({super.key, this.tamanho = 36});

  final double tamanho;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(tamanho),
    painter: _Grade(
      letras: const ['C', '', '#', 'S', 'O', 'L', '#', 'R', ''],
      destaque: const [(1, 0), (1, 1), (1, 2)],
      casaPreta: true,
    ),
  );
}

/// Desenho pequeno de caça-palavras: letras soltas com a palavra LUA
/// marcada.
class IconeCaca extends StatelessWidget {
  const IconeCaca({super.key, this.tamanho = 36});

  final double tamanho;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(tamanho),
    painter: _Grade(
      letras: const ['M', 'A', 'R', 'L', 'U', 'A', 'P', 'E', 'Z'],
      destaque: const [(1, 0), (1, 2)],
      casaPreta: false,
    ),
  );
}

class _Grade extends CustomPainter {
  _Grade({
    required this.letras,
    required this.destaque,
    required this.casaPreta,
  });

  /// 9 casas, linha por linha. '#' = casa preta; '' = casa vazia.
  final List<String> letras;

  /// Cruzadas: casas pintadas de verde. Caça: início e fim da marcação.
  final List<(int, int)> destaque;
  final bool casaPreta;

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.width / 3;
    final borda = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.14),
    );
    canvas.save();
    canvas.clipRRect(borda);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    if (casaPreta) {
      for (var i = 0; i < 9; i++) {
        final r = Rect.fromLTWH((i % 3) * lado, (i ~/ 3) * lado, lado, lado);
        final verde = destaque.contains((i ~/ 3, i % 3));
        if (letras[i] == '#') {
          canvas.drawRect(r, Paint()..color = const Color(0xFF1B2A1B));
        } else if (verde) {
          canvas.drawRect(
            r,
            Paint()..color = CoresMarca.verdeClaro.withValues(alpha: 0.55),
          );
        }
      }
      // Linhas da grade.
      final linha = Paint()
        ..color = const Color(0xFF1B2A1B)
        ..strokeWidth = size.width * 0.03;
      for (var k = 1; k < 3; k++) {
        canvas.drawLine(
          Offset(k * lado, 0),
          Offset(k * lado, size.height),
          linha,
        );
        canvas.drawLine(
          Offset(0, k * lado),
          Offset(size.width, k * lado),
          linha,
        );
      }
    } else {
      final (a, b) = (destaque.first, destaque.last);
      canvas.drawLine(
        Offset((a.$2 + 0.5) * lado, (a.$1 + 0.5) * lado),
        Offset((b.$2 + 0.5) * lado, (b.$1 + 0.5) * lado),
        Paint()
          ..color = CoresMarca.amarelo.withValues(alpha: 0.8)
          ..strokeWidth = lado * 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < 9; i++) {
      final letra = letras[i];
      if (letra.isEmpty || letra == '#') continue;
      final tp = TextPainter(
        text: TextSpan(
          text: letra,
          style: TextStyle(
            fontSize: lado * 0.62,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2A1B),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          (i % 3 + 0.5) * lado - tp.width / 2,
          (i ~/ 3 + 0.5) * lado - tp.height / 2,
        ),
      );
    }
    canvas.restore();
    canvas.drawRRect(
      borda,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04
        ..color = const Color(0xFF1B2A1B),
    );
  }

  @override
  bool shouldRepaint(_Grade old) => false;
}
