import 'nivel.dart';

/// Uma palavra já colocada na grade.
class PalavraNaGrade {
  const PalavraNaGrade({
    required this.resposta,
    required this.escrita,
    required this.dica,
    required this.linha,
    required this.coluna,
    required this.horizontal,
    required this.numero,
  });

  factory PalavraNaGrade.deJson(Map<String, dynamic> json) => PalavraNaGrade(
    resposta: json['resposta'] as String,
    escrita: json['escrita'] as String,
    dica: json['dica'] as String,
    linha: json['linha'] as int,
    coluna: json['coluna'] as int,
    horizontal: json['horizontal'] as bool,
    numero: json['numero'] as int,
  );

  /// Resposta no formato da grade, sem acentos ("LEAO").
  final String resposta;

  /// Palavra como se escreve ("LEÃO"), mostrada no fim do desafio.
  final String escrita;
  final String dica;
  final int linha;
  final int coluna;
  final bool horizontal;

  /// Número que aparece na casa inicial e na lista de dicas.
  final int numero;

  int get tamanho => resposta.length;

  /// Linha e coluna da i-ésima letra.
  (int, int) casa(int i) =>
      horizontal ? (linha, coluna + i) : (linha + i, coluna);

  Iterable<(int, int)> get casas => Iterable.generate(tamanho, casa);

  Map<String, dynamic> paraJson() => {
    'resposta': resposta,
    'escrita': escrita,
    'dica': dica,
    'linha': linha,
    'coluna': coluna,
    'horizontal': horizontal,
    'numero': numero,
  };
}

/// Uma grade de palavras cruzadas pronta para jogar (estilo americano:
/// casas vazias são pretas e as dicas ficam numeradas numa lista).
class DesafioCruzadas {
  DesafioCruzadas({
    required this.tamanho,
    required this.nivel,
    required this.temas,
    required this.semente,
    required this.palavras,
  }) : _letras = _montarLetras(tamanho, palavras);

  factory DesafioCruzadas.deJson(Map<String, dynamic> json) => DesafioCruzadas(
    tamanho: json['tamanho'] as int,
    nivel: Nivel.porNome(json['nivel'] as String),
    temas: List<String>.from(json['temas'] as List),
    semente: json['semente'] as int,
    palavras: (json['palavras'] as List)
        .map((p) => PalavraNaGrade.deJson(p as Map<String, dynamic>))
        .toList(),
  );

  final int tamanho;
  final Nivel nivel;

  /// Ids dos temas usados (nomes dos arquivos JSON).
  final List<String> temas;
  final int semente;
  final List<PalavraNaGrade> palavras;
  final List<String?> _letras;

  /// Identificador estável: o mesmo desafio sempre tem o mesmo id.
  String get id => 'cruzadas:${nivel.name}:${temas.join('+')}:$semente';

  int indice(int linha, int coluna) => linha * tamanho + coluna;

  /// Letra certa da casa, ou null se a casa é preta.
  String? letra(int linha, int coluna) => _letras[indice(linha, coluna)];

  bool ehBloqueada(int linha, int coluna) => letra(linha, coluna) == null;

  /// Quantas casas têm letra.
  int get totalLetras => _letras.whereType<String>().length;

  /// Tempo-alvo em segundos, usado no bônus de tempo.
  int get tempoAlvoSegundos => totalLetras * nivel.segundosPorLetra;

  /// Número mostrado no canto da casa, se alguma palavra começa nela.
  int? numeroDaCasa(int linha, int coluna) {
    for (final p in palavras) {
      if (p.linha == linha && p.coluna == coluna) return p.numero;
    }
    return null;
  }

  /// Palavra que passa pela casa na direção pedida.
  PalavraNaGrade? palavraEm(int linha, int coluna, {required bool horizontal}) {
    for (final p in palavras) {
      if (p.horizontal != horizontal) continue;
      for (final (l, c) in p.casas) {
        if (l == linha && c == coluna) return p;
      }
    }
    return null;
  }

  Map<String, dynamic> paraJson() => {
    'tamanho': tamanho,
    'nivel': nivel.name,
    'temas': temas,
    'semente': semente,
    'palavras': palavras.map((p) => p.paraJson()).toList(),
  };

  static List<String?> _montarLetras(
    int tamanho,
    List<PalavraNaGrade> palavras,
  ) {
    final letras = List<String?>.filled(tamanho * tamanho, null);
    for (final p in palavras) {
      for (var i = 0; i < p.tamanho; i++) {
        final (l, c) = p.casa(i);
        letras[l * tamanho + c] = p.resposta[i];
      }
    }
    return letras;
  }
}
