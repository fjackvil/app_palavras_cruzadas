/// Níveis do jogo. Na fase 1 só Leve e Médio estão liberados.
enum Nivel {
  leve(
    nome: 'Leve',
    multiplicador: 1,
    tamanhoGrade: 7,
    minLetras: 3,
    maxLetras: 6,
    maxDificuldade: 1,
    metaPalavras: 6,
    segundosPorLetra: 8,
  ),
  medio(
    nome: 'Médio',
    multiplicador: 1.5,
    tamanhoGrade: 10,
    minLetras: 3,
    maxLetras: 8,
    maxDificuldade: 2,
    metaPalavras: 11,
    segundosPorLetra: 6,
  );

  const Nivel({
    required this.nome,
    required this.multiplicador,
    required this.tamanhoGrade,
    required this.minLetras,
    required this.maxLetras,
    required this.maxDificuldade,
    required this.metaPalavras,
    required this.segundosPorLetra,
  });

  final String nome;

  /// Multiplicador dos pontos por letra (Leve ×1, Médio ×1,5).
  final double multiplicador;

  /// A grade é quadrada: tamanhoGrade × tamanhoGrade.
  final int tamanhoGrade;
  final int minLetras;
  final int maxLetras;

  /// Maior dificuldade (1–4) das palavras usadas no nível.
  final int maxDificuldade;

  /// Quantas palavras o gerador tenta encaixar.
  final int metaPalavras;

  /// Usado para calcular o tempo-alvo do desafio.
  final int segundosPorLetra;

  /// Nível sugerido pela idade. Na fase 1, de 10 anos para cima é Médio.
  static Nivel sugeridoParaIdade(int idade) =>
      idade <= 9 ? Nivel.leve : Nivel.medio;

  static Nivel porNome(String nome) =>
      Nivel.values.firstWhere((n) => n.name == nome, orElse: () => Nivel.leve);
}
