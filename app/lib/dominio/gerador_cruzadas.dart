import 'dart:math';

import 'desafio.dart';
import 'nivel.dart';
import 'tema.dart';

/// Monta grades de palavras cruzadas no próprio celular.
///
/// Faz várias tentativas com ordens diferentes de palavras e fica com a
/// grade que encaixou mais palavras. Tudo depende só da [semente], então a
/// mesma semente gera sempre a mesma grade (base do desafio diário).
class GeradorCruzadas {
  const GeradorCruzadas({this.tentativas = 60, this.limiteCandidatas = 150});

  final int tentativas;

  /// Quantas palavras cada tentativa testa, no máximo. Com "Misturado" há
  /// milhares de candidatas; testar todas deixaria a grade lenta de montar.
  final int limiteCandidatas;

  DesafioCruzadas gerar({
    required List<Tema> temas,
    required Nivel nivel,
    required int semente,
    String? diario,
  }) {
    final candidatas = _candidatas(temas, nivel);
    if (candidatas.length < 2) {
      throw StateError('Palavras insuficientes para o nível ${nivel.nome}.');
    }
    final aleatorio = Random(semente);
    _Tentativa? melhor;
    for (var t = 0; t < tentativas; t++) {
      final ordem = ([
        ...candidatas,
      ]..shuffle(aleatorio)).take(limiteCandidatas).toList();
      final tentativa = _Tentativa(nivel.tamanhoGrade)
        ..preencher(ordem, nivel.metaPalavras, aleatorio);
      if (melhor == null || tentativa.melhorQue(melhor)) melhor = tentativa;
      if (melhor.colocadas.length >= nivel.metaPalavras) break;
    }
    return DesafioCruzadas(
      tamanho: nivel.tamanhoGrade,
      nivel: nivel,
      temas: temas.map((t) => t.id).toList(),
      semente: semente,
      diario: diario,
      palavras: melhor!.numerar(nivel),
    );
  }

  /// Palavras do nível, sem repetir a mesma grafia, numa ordem fixa.
  List<Palavra> _candidatas(List<Tema> temas, Nivel nivel) {
    final porGrade = <String, Palavra>{};
    for (final tema in temas) {
      for (final p in tema.palavrasPara(nivel)) {
        if (p.grade.length <= nivel.tamanhoGrade) {
          porGrade.putIfAbsent(p.grade, () => p);
        }
      }
    }
    final lista = porGrade.values.toList()
      ..sort((a, b) => a.grade.compareTo(b.grade));
    return lista;
  }
}

class _Colocada {
  _Colocada(this.palavra, this.linha, this.coluna, this.horizontal);

  final Palavra palavra;
  final int linha;
  final int coluna;
  final bool horizontal;
}

class _Tentativa {
  _Tentativa(this.tamanho)
    : letras = List<String?>.filled(tamanho * tamanho, null),
      usoHorizontal = List<bool>.filled(tamanho * tamanho, false),
      usoVertical = List<bool>.filled(tamanho * tamanho, false);

  final int tamanho;
  final List<String?> letras;
  final List<bool> usoHorizontal;
  final List<bool> usoVertical;
  final colocadas = <_Colocada>[];
  int cruzamentos = 0;

  bool melhorQue(_Tentativa outra) {
    if (colocadas.length != outra.colocadas.length) {
      return colocadas.length > outra.colocadas.length;
    }
    return cruzamentos > outra.cruzamentos;
  }

  void preencher(List<Palavra> ordem, int meta, Random aleatorio) {
    final restantes = [...ordem];
    // A primeira palavra entra na horizontal, numa linha central.
    final primeira = restantes.removeAt(0);
    final linha = tamanho ~/ 2 - (aleatorio.nextBool() ? 1 : 0);
    final folga = tamanho - primeira.grade.length;
    _colocar(primeira, linha, aleatorio.nextInt(folga + 1), true);

    // Duas passadas: palavras que não couberam na primeira podem caber
    // depois que outras abriram novos cruzamentos.
    for (var passada = 0; passada < 2 && colocadas.length < meta; passada++) {
      for (final palavra in [...restantes]) {
        if (colocadas.length >= meta) break;
        final opcoes = _posicoes(palavra);
        if (opcoes.isEmpty) continue;
        // Prefere posições com mais cruzamentos; desempata ao acaso.
        final maxCruz = opcoes.map((o) => o.$4).reduce(max);
        final melhores = opcoes.where((o) => o.$4 == maxCruz).toList();
        final (l, c, h, _) = melhores[aleatorio.nextInt(melhores.length)];
        _colocar(palavra, l, c, h);
        restantes.remove(palavra);
      }
    }
  }

  int _i(int l, int c) => l * tamanho + c;

  bool _dentro(int l, int c) => l >= 0 && c >= 0 && l < tamanho && c < tamanho;

  bool _vazia(int l, int c) => !_dentro(l, c) || letras[_i(l, c)] == null;

  /// Todas as posições válidas que cruzam pelo menos uma letra.
  List<(int, int, bool, int)> _posicoes(Palavra palavra) {
    final resultado = <(int, int, bool, int)>[];
    final texto = palavra.grade;
    for (var l = 0; l < tamanho; l++) {
      for (var c = 0; c < tamanho; c++) {
        for (final horizontal in const [true, false]) {
          final cruz = _cruzamentos(texto, l, c, horizontal);
          if (cruz > 0) resultado.add((l, c, horizontal, cruz));
        }
      }
    }
    return resultado;
  }

  /// Quantos cruzamentos a palavra teria ali, ou -1 se não pode.
  int _cruzamentos(String texto, int l, int c, bool horizontal) {
    final dl = horizontal ? 0 : 1;
    final dc = horizontal ? 1 : 0;
    final fimL = l + dl * (texto.length - 1);
    final fimC = c + dc * (texto.length - 1);
    if (!_dentro(l, c) || !_dentro(fimL, fimC)) return -1;
    // Antes do começo e depois do fim precisa ter casa preta ou borda.
    if (!_vazia(l - dl, c - dc) || !_vazia(fimL + dl, fimC + dc)) return -1;

    var cruz = 0;
    for (var k = 0; k < texto.length; k++) {
      final ll = l + dl * k;
      final cc = c + dc * k;
      final atual = letras[_i(ll, cc)];
      if (atual != null) {
        if (atual != texto[k]) return -1;
        final usada = horizontal
            ? usoHorizontal[_i(ll, cc)]
            : usoVertical[_i(ll, cc)];
        if (usada) return -1;
        cruz++;
      } else {
        // Casa nova: os vizinhos laterais precisam estar vazios para não
        // formar palavras que não existem.
        if (!_vazia(ll - dc, cc - dl) || !_vazia(ll + dc, cc + dl)) return -1;
      }
    }
    return cruz;
  }

  void _colocar(Palavra palavra, int l, int c, bool horizontal) {
    final texto = palavra.grade;
    for (var k = 0; k < texto.length; k++) {
      final ll = horizontal ? l : l + k;
      final cc = horizontal ? c + k : c;
      final i = _i(ll, cc);
      if (letras[i] != null) cruzamentos++;
      letras[i] = texto[k];
      if (horizontal) {
        usoHorizontal[i] = true;
      } else {
        usoVertical[i] = true;
      }
    }
    colocadas.add(_Colocada(palavra, l, c, horizontal));
  }

  /// Numera como nas cruzadas americanas: da esquerda para a direita, de
  /// cima para baixo; palavras que começam na mesma casa dividem o número.
  List<PalavraNaGrade> numerar(Nivel nivel) {
    final inicios = colocadas.map((p) => _i(p.linha, p.coluna)).toSet().toList()
      ..sort();
    final numeros = {
      for (var n = 0; n < inicios.length; n++) inicios[n]: n + 1,
    };
    final lista =
        colocadas
            .map(
              (p) => PalavraNaGrade(
                resposta: p.palavra.grade,
                escrita: p.palavra.palavra,
                dica: p.palavra.dicaPara(nivel),
                linha: p.linha,
                coluna: p.coluna,
                horizontal: p.horizontal,
                numero: numeros[_i(p.linha, p.coluna)]!,
              ),
            )
            .toList()
          ..sort((a, b) {
            if (a.horizontal != b.horizontal) return a.horizontal ? -1 : 1;
            return a.numero.compareTo(b.numero);
          });
    return lista;
  }
}
