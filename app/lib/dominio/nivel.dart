/// Os níveis da especificação. Pequenos (4 a 5 anos) entrou em 18/11/2026.
enum Nivel {
  pequenos(
    nome: 'Pequenos',
    nomeCurto: 'Pequenos',
    multiplicador: 1,
    tamanhoGrade: 6,
    minLetras: 3,
    maxLetras: 6,
    maxDificuldade: 1,
    metaPalavras: 4,
    segundosPorLetra: 12,
    chaveDica: 'pequenos',
  ),
  leve(
    nome: 'Leve',
    nomeCurto: 'Leve',
    multiplicador: 1,
    tamanhoGrade: 7,
    minLetras: 3,
    maxLetras: 6,
    maxDificuldade: 1,
    metaPalavras: 6,
    segundosPorLetra: 8,
    chaveDica: 'leve',
  ),
  medio(
    nome: 'Médio',
    nomeCurto: 'Médio',
    multiplicador: 1.5,
    tamanhoGrade: 10,
    minLetras: 4,
    maxLetras: 8,
    maxDificuldade: 2,
    metaPalavras: 11,
    segundosPorLetra: 6,
    chaveDica: 'media',
  ),
  dificil(
    nome: 'Difícil',
    nomeCurto: 'Difícil',
    multiplicador: 2,
    tamanhoGrade: 13,
    minLetras: 4,
    maxLetras: 10,
    maxDificuldade: 3,
    metaPalavras: 16,
    segundosPorLetra: 5,
    chaveDica: 'dificil',
  ),
  superDificil(
    nome: 'Super difícil',
    nomeCurto: 'Super',
    multiplicador: 3,
    tamanhoGrade: 15,
    minLetras: 4,
    maxLetras: 13,
    maxDificuldade: 4,
    metaPalavras: 22,
    segundosPorLetra: 5,
    chaveDica: 'dificil',
  );

  const Nivel({
    required this.nome,
    required this.nomeCurto,
    required this.multiplicador,
    required this.tamanhoGrade,
    required this.minLetras,
    required this.maxLetras,
    required this.maxDificuldade,
    required this.metaPalavras,
    required this.segundosPorLetra,
    required this.chaveDica,
  });

  final String nome;

  /// Nome que cabe no seletor de níveis.
  final String nomeCurto;

  /// Multiplicador dos pontos por letra (Leve ×1 até Super difícil ×3).
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

  /// Qual dica do JSON o nível mostra ('leve', 'media' ou 'dificil'). No
  /// Pequenos a dica é o desenho (campo 'emoji' da palavra).
  final String chaveDica;

  /// Nível sugerido pela idade. Super difícil fica para quem escolher.
  static Nivel sugeridoParaIdade(int idade) {
    if (idade <= 5) return Nivel.pequenos;
    if (idade <= 9) return Nivel.leve;
    if (idade <= 13) return Nivel.medio;
    return Nivel.dificil;
  }

  /// Pequenos e Leve: a primeira letra de cada palavra já vem escrita e as
  /// letras ficam maiores.
  bool get facil => index <= Nivel.leve.index;

  /// Só entram palavras com desenho, e o desenho é a dica.
  bool get soComDesenho => this == Nivel.pequenos;

  static Nivel porNome(String nome) =>
      Nivel.values.firstWhere((n) => n.name == nome, orElse: () => Nivel.leve);
}
