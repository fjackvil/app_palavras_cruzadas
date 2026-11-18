import 'dart:math';

/// Pergunta da "porta dos pais": uma multiplicação que uma criança pequena
/// não resolve sozinha. Fica antes da compra do Premium, para evitar compra
/// por engano no celular dos pais.
class PerguntaPais {
  const PerguntaPais(this.a, this.b);

  /// Números de 6 a 9: resultado de dois dígitos (36 a 81).
  factory PerguntaPais.sortear([Random? sorte]) {
    final r = sorte ?? Random();
    return PerguntaPais(6 + r.nextInt(4), 6 + r.nextInt(4));
  }

  final int a;
  final int b;

  int get resposta => a * b;

  String get texto => 'Quanto é $a × $b?';

  bool confere(String digitado) => int.tryParse(digitado.trim()) == resposta;
}
