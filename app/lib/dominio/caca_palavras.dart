import 'dart:math';

import 'nivel.dart';
import 'tema.dart';

/// As 8 direções em que uma palavra pode estar escondida.
enum Direcao {
  direita(0, 1),
  baixo(1, 0),
  diagonalDesce(1, 1),
  diagonalSobe(-1, 1),
  esquerda(0, -1),
  cima(-1, 0),
  diagonalDesceVolta(1, -1),
  diagonalSobeVolta(-1, -1);

  const Direcao(this.dl, this.dc);

  final int dl;
  final int dc;

  /// Direção a partir de dois pontos alinhados, ou null se não estão numa
  /// linha reta (horizontal, vertical ou diagonal).
  static Direcao? entre(int l1, int c1, int l2, int c2) {
    final dl = (l2 - l1).sign;
    final dc = (c2 - c1).sign;
    if (dl == 0 && dc == 0) return null;
    final retas = l1 == l2 || c1 == c2 || (l2 - l1).abs() == (c2 - c1).abs();
    if (!retas) return null;
    return Direcao.values.firstWhere((d) => d.dl == dl && d.dc == dc);
  }
}

/// Regras do caça-palavras por nível (tabela da especificação).
class RegrasCaca {
  const RegrasCaca({
    required this.tamanho,
    required this.quantidade,
    required this.direcoes,
    required this.mostrarPalavras,
    required this.minLetras,
    required this.segundosPorPalavra,
  });

  final int tamanho;
  final int quantidade;
  final List<Direcao> direcoes;

  /// No Super difícil a lista mostra só as dicas, sem as palavras.
  final bool mostrarPalavras;
  final int minLetras;

  /// Usado para o tempo-alvo do bônus de tempo.
  final int segundosPorPalavra;

  /// Em todos os níveis as palavras podem estar em qualquer uma das 8
  /// direções (decisão do Fernando em 16/11/2026); o nível muda o tamanho
  /// da grade, a quantidade de palavras e a lista.
  static const todasDirecoes = Direcao.values;

  static RegrasCaca de(Nivel nivel) => switch (nivel) {
    Nivel.leve => const RegrasCaca(
      tamanho: 8,
      quantidade: 6,
      direcoes: todasDirecoes,
      mostrarPalavras: true,
      minLetras: 3,
      segundosPorPalavra: 30,
    ),
    Nivel.medio => const RegrasCaca(
      tamanho: 10,
      quantidade: 8,
      direcoes: todasDirecoes,
      mostrarPalavras: true,
      minLetras: 4,
      segundosPorPalavra: 30,
    ),
    Nivel.dificil => const RegrasCaca(
      tamanho: 12,
      quantidade: 10,
      direcoes: todasDirecoes,
      mostrarPalavras: true,
      minLetras: 4,
      segundosPorPalavra: 30,
    ),
    Nivel.superDificil => const RegrasCaca(
      tamanho: 12,
      quantidade: 12,
      direcoes: todasDirecoes,
      mostrarPalavras: false,
      minLetras: 4,
      segundosPorPalavra: 45,
    ),
  };
}

/// Palavras do tema que cabem no caça-palavras do nível.
List<Palavra> palavrasDoCaca(Tema tema, Nivel nivel) {
  final regras = RegrasCaca.de(nivel);
  return tema.palavras
      .where(
        (p) =>
            p.dificuldade <= nivel.maxDificuldade &&
            p.grade.length >= regras.minLetras &&
            p.grade.length <= regras.tamanho,
      )
      .toList();
}

/// Se o tema tem palavras suficientes para o caça-palavras do nível.
bool temaServeParaCaca(Tema tema, Nivel nivel) =>
    palavrasDoCaca(tema, nivel).length >= RegrasCaca.de(nivel).quantidade * 2;

/// Uma palavra escondida na grade.
class PalavraEscondida {
  const PalavraEscondida({
    required this.resposta,
    required this.escrita,
    required this.dica,
    required this.linha,
    required this.coluna,
    required this.direcao,
  });

  factory PalavraEscondida.deJson(Map<String, dynamic> json) =>
      PalavraEscondida(
        resposta: json['resposta'] as String,
        escrita: json['escrita'] as String,
        dica: json['dica'] as String,
        linha: json['linha'] as int,
        coluna: json['coluna'] as int,
        direcao: Direcao.values.byName(json['direcao'] as String),
      );

  /// Como está na grade, sem acentos ("LEAO").
  final String resposta;

  /// Como se escreve ("LEÃO"), mostrada na lista.
  final String escrita;
  final String dica;
  final int linha;
  final int coluna;
  final Direcao direcao;

  int get tamanho => resposta.length;

  (int, int) casa(int i) => (linha + direcao.dl * i, coluna + direcao.dc * i);

  List<(int, int)> get casas => List.generate(tamanho, casa);

  Map<String, dynamic> paraJson() => {
    'resposta': resposta,
    'escrita': escrita,
    'dica': dica,
    'linha': linha,
    'coluna': coluna,
    'direcao': direcao.name,
  };
}

/// Uma grade de caça-palavras pronta para jogar.
class DesafioCaca {
  DesafioCaca({
    required this.tamanho,
    required this.nivel,
    required this.temas,
    required this.semente,
    required this.letras,
    required this.palavras,
    this.diario,
  });

  factory DesafioCaca.deJson(Map<String, dynamic> json) => DesafioCaca(
    tamanho: json['tamanho'] as int,
    nivel: Nivel.porNome(json['nivel'] as String),
    temas: List<String>.from(json['temas'] as List),
    semente: json['semente'] as int,
    diario: json['diario'] as String?,
    letras: (json['letras'] as String).split(''),
    palavras: (json['palavras'] as List)
        .map((p) => PalavraEscondida.deJson(p as Map<String, dynamic>))
        .toList(),
  );

  static const modo = 'caca_palavras';

  final int tamanho;
  final Nivel nivel;
  final List<String> temas;
  final int semente;
  final String? diario;

  /// Letras da grade, linha por linha (tamanho × tamanho).
  final List<String> letras;
  final List<PalavraEscondida> palavras;

  RegrasCaca get regras => RegrasCaca.de(nivel);

  String get id => diario != null
      ? idDiario(nivel, diario!)
      : 'caca:${nivel.name}:${temas.join('+')}:$semente';

  static String idDiario(Nivel nivel, String data) =>
      'caca:diario:${nivel.name}:$data';

  String letra(int linha, int coluna) => letras[linha * tamanho + coluna];

  int get totalLetras => palavras.fold(0, (s, p) => s + p.tamanho);

  int get tempoAlvoSegundos => palavras.length * regras.segundosPorPalavra;

  Map<String, dynamic> paraJson() => {
    'tamanho': tamanho,
    'nivel': nivel.name,
    'temas': temas,
    'semente': semente,
    'diario': ?diario,
    'letras': letras.join(),
    'palavras': palavras.map((p) => p.paraJson()).toList(),
  };
}

/// Monta o caça-palavras no próprio celular. A mesma semente sempre dá a
/// mesma grade (o desafio diário depende disso).
class GeradorCaca {
  const GeradorCaca({this.tentativasPorPalavra = 200});

  final int tentativasPorPalavra;

  /// Letras de preenchimento, com a frequência aproximada do português, para
  /// a grade não parecer sorteada demais.
  static const _preenchimento =
      'AAAAAAAAAAAAAEEEEEEEEEEEOOOOOOOOOOSSSSSSSRRRRRRIIIIIINNNNN'
      'DDDDDMMMMMUUUUUTTTTTCCCCLLLPPPVVGGHQBFZJX';

  DesafioCaca gerar({
    required List<Tema> temas,
    required Nivel nivel,
    required int semente,
    String? diario,
  }) {
    final regras = RegrasCaca.de(nivel);
    final n = regras.tamanho;
    final aleatorio = Random(semente);

    // Candidatas sem repetir a grafia e sem uma ser pedaço da outra
    // (senão achar "MAR" dentro de "MARTE" confundiria).
    final vistas = <String>{};
    final candidatas = <Palavra>[];
    for (final t in temas) {
      for (final p in palavrasDoCaca(t, nivel)) {
        if (vistas.add(p.grade)) candidatas.add(p);
      }
    }
    candidatas.sort((a, b) => a.grade.compareTo(b.grade));
    candidatas.shuffle(aleatorio);

    final grade = List<String?>.filled(n * n, null);
    final colocadas = <PalavraEscondida>[];
    for (final p in candidatas) {
      if (colocadas.length >= regras.quantidade) break;
      if (colocadas.any(
        (c) => c.resposta.contains(p.grade) || p.grade.contains(c.resposta),
      )) {
        continue;
      }
      final lugar = _procurarLugar(p.grade, regras, grade, aleatorio);
      if (lugar == null) continue;
      final escondida = PalavraEscondida(
        resposta: p.grade,
        escrita: p.palavra,
        dica: p.dicaPara(nivel),
        linha: lugar.$1,
        coluna: lugar.$2,
        direcao: lugar.$3,
      );
      for (var i = 0; i < escondida.tamanho; i++) {
        final (l, c) = escondida.casa(i);
        grade[l * n + c] = escondida.resposta[i];
      }
      colocadas.add(escondida);
    }

    final letras = [
      for (final l in grade)
        l ?? _preenchimento[aleatorio.nextInt(_preenchimento.length)],
    ];
    return DesafioCaca(
      tamanho: n,
      nivel: nivel,
      temas: temas.map((t) => t.id).toList(),
      semente: semente,
      diario: diario,
      letras: letras,
      palavras: colocadas,
    );
  }

  (int, int, Direcao)? _procurarLugar(
    String palavra,
    RegrasCaca regras,
    List<String?> grade,
    Random aleatorio,
  ) {
    final n = regras.tamanho;
    for (var t = 0; t < tentativasPorPalavra; t++) {
      final d = regras.direcoes[aleatorio.nextInt(regras.direcoes.length)];
      final l = aleatorio.nextInt(n);
      final c = aleatorio.nextInt(n);
      final lf = l + d.dl * (palavra.length - 1);
      final cf = c + d.dc * (palavra.length - 1);
      if (lf < 0 || lf >= n || cf < 0 || cf >= n) continue;
      var cabe = true;
      for (var i = 0; i < palavra.length && cabe; i++) {
        final atual = grade[(l + d.dl * i) * n + (c + d.dc * i)];
        cabe = atual == null || atual == palavra[i];
      }
      if (cabe) return (l, c, d);
    }
    return null;
  }
}
