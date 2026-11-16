import 'package:flutter/foundation.dart';

import 'desafio.dart';
import 'nivel.dart';
import 'pontuacao.dart';

/// Estado de uma partida de cruzadas em andamento.
///
/// Não sabe nada de telas nem de banco: a tela escuta as mudanças e o
/// banco guarda o que [paraJson] devolve.
class JogoCruzadas extends ChangeNotifier {
  JogoCruzadas(
    this.desafio, {
    List<String>? respostas,
    Set<int>? reveladas,
    this.dicasLetra = 0,
    this.dicasPalavra = 0,
    this.segundos = 0,
  }) : respostas =
           respostas ??
           List<String>.filled(desafio.tamanho * desafio.tamanho, ''),
       reveladas = reveladas ?? <int>{} {
    // No nível Leve a primeira letra de cada palavra já vem escrita.
    if (desafio.nivel == Nivel.leve) {
      for (final p in desafio.palavras) {
        final (l, c) = p.casa(0);
        final i = desafio.indice(l, c);
        fixas.add(i);
        this.respostas[i] = p.resposta[0];
      }
    }
    _selecionarPrimeira();
  }

  factory JogoCruzadas.deJson(
    DesafioCruzadas desafio,
    Map<String, dynamic> json,
  ) => JogoCruzadas(
    desafio,
    respostas: List<String>.from(json['respostas'] as List),
    reveladas: Set<int>.from(json['reveladas'] as List),
    dicasLetra: json['dicasLetra'] as int? ?? 0,
    dicasPalavra: json['dicasPalavra'] as int? ?? 0,
    segundos: json['segundos'] as int? ?? 0,
  );

  final DesafioCruzadas desafio;

  /// Letra digitada em cada casa ('' quando vazia).
  final List<String> respostas;

  /// Casas abertas por dica (não podem ser apagadas).
  final Set<int> reveladas;

  /// Casas que já vêm escritas (primeira letra no nível Leve).
  final Set<int> fixas = {};

  /// Casas marcadas como erradas pelo botão "verificar".
  final Set<int> erradas = {};

  int dicasLetra;
  int dicasPalavra;
  int segundos;

  int linha = 0;
  int coluna = 0;
  bool horizontal = true;

  Nivel get nivel => desafio.nivel;
  int get dicasUsadas => dicasLetra + dicasPalavra;

  int get _atual => desafio.indice(linha, coluna);

  PalavraNaGrade? get palavraAtual =>
      desafio.palavraEm(linha, coluna, horizontal: horizontal);

  bool travada(int i) => fixas.contains(i) || reveladas.contains(i);

  /// Toca numa casa. Tocar de novo na mesma casa troca a direção.
  void tocar(int l, int c) {
    if (desafio.ehBloqueada(l, c)) return;
    final temH = desafio.palavraEm(l, c, horizontal: true) != null;
    final temV = desafio.palavraEm(l, c, horizontal: false) != null;
    if (l == linha && c == coluna && temH && temV) {
      horizontal = !horizontal;
    } else {
      linha = l;
      coluna = c;
      if (horizontal && !temH) horizontal = false;
      if (!horizontal && !temV) horizontal = true;
    }
    notifyListeners();
  }

  /// Seleciona a primeira casa livre de uma palavra (lista de dicas).
  void selecionarPalavra(PalavraNaGrade p) {
    _irPara(p);
    notifyListeners();
  }

  void _irPara(PalavraNaGrade p) {
    horizontal = p.horizontal;
    final livre = p.casas.firstWhere((casa) {
      final i = desafio.indice(casa.$1, casa.$2);
      return !travada(i) && !_certa(i);
    }, orElse: () => p.casa(0));
    linha = livre.$1;
    coluna = livre.$2;
  }

  /// Se a palavra [p] ficou certa, vai para a próxima palavra que falta
  /// (na ordem da lista de dicas). Devolve true se mudou de palavra.
  bool _seCompletaIrParaProxima(PalavraNaGrade? p) {
    if (p == null || !palavraCompleta(p)) return false;
    final lista = desafio.palavras;
    final inicio = lista.indexOf(p);
    for (var k = 1; k < lista.length; k++) {
      final q = lista[(inicio + k) % lista.length];
      if (!palavraCompleta(q)) {
        _irPara(q);
        return true;
      }
    }
    return false;
  }

  void digitar(String letra) {
    if (concluido) return;
    final i = _atual;
    if (!travada(i)) {
      respostas[i] = letra;
      erradas.remove(i);
    }
    if (!_seCompletaIrParaProxima(palavraAtual)) _avancar();
    notifyListeners();
  }

  void apagar() {
    final i = _atual;
    if (!travada(i) && respostas[i].isNotEmpty) {
      respostas[i] = '';
      erradas.remove(i);
    } else {
      _voltar();
      final j = _atual;
      if (!travada(j)) {
        respostas[j] = '';
        erradas.remove(j);
      }
    }
    notifyListeners();
  }

  /// Revela a casa selecionada (ou a primeira errada da palavra).
  void dicaDeLetra() {
    final p = palavraAtual;
    if (p == null || concluido) return;
    var alvo = _atual;
    if (travada(alvo) || _certa(alvo)) {
      final pendente = p.casas
          .map((c) => desafio.indice(c.$1, c.$2))
          .where((i) => !travada(i) && !_certa(i));
      if (pendente.isEmpty) return;
      alvo = pendente.first;
    }
    _revelar(alvo);
    dicasLetra++;
    _seCompletaIrParaProxima(p);
    notifyListeners();
  }

  /// Revela a palavra selecionada inteira.
  void dicaDePalavra() {
    final p = palavraAtual;
    if (p == null || concluido || palavraCompleta(p)) return;
    for (final (l, c) in p.casas) {
      final i = desafio.indice(l, c);
      if (!travada(i) && !_certa(i)) _revelar(i);
    }
    dicasPalavra++;
    _seCompletaIrParaProxima(p);
    notifyListeners();
  }

  /// Marca de vermelho as letras erradas da palavra selecionada.
  /// Devolve true se a palavra está toda certa.
  bool verificarPalavra() {
    final p = palavraAtual;
    if (p == null) return false;
    var certa = true;
    for (final (l, c) in p.casas) {
      final i = desafio.indice(l, c);
      if (respostas[i].isEmpty) {
        certa = false;
      } else if (!_certa(i)) {
        erradas.add(i);
        certa = false;
      }
    }
    if (certa) _seCompletaIrParaProxima(p);
    notifyListeners();
    return certa;
  }

  bool palavraCompleta(PalavraNaGrade p) =>
      p.casas.every((c) => _certa(desafio.indice(c.$1, c.$2)));

  bool get concluido {
    for (var i = 0; i < respostas.length; i++) {
      final certa = desafio.letra(i ~/ desafio.tamanho, i % desafio.tamanho);
      if (certa != null && respostas[i] != certa) return false;
    }
    return true;
  }

  /// Quantas letras certas estão na grade agora.
  int get letrasCertas {
    var n = 0;
    for (var i = 0; i < respostas.length; i++) {
      if (_certa(i)) n++;
    }
    return n;
  }

  void contarSegundo() {
    segundos++;
    notifyListeners();
  }

  Pontuacao get pontuacao => Pontuacao.calcular(
    nivel: nivel,
    letras: letrasCertas,
    segundos: segundos,
    tempoAlvoSegundos: desafio.tempoAlvoSegundos,
    dicasLetra: dicasLetra,
    dicasPalavra: dicasPalavra,
  );

  /// "Ver resposta": completa a grade. O que faltava fica azul, como nas
  /// dicas, para a pessoa ver o que não acertou.
  void revelarTudo() {
    for (var i = 0; i < respostas.length; i++) {
      final certa = desafio.letra(i ~/ desafio.tamanho, i % desafio.tamanho);
      if (certa != null && respostas[i] != certa) _revelar(i);
    }
    erradas.clear();
    notifyListeners();
  }

  Map<String, dynamic> paraJson() => {
    'respostas': respostas,
    'reveladas': reveladas.toList(),
    'dicasLetra': dicasLetra,
    'dicasPalavra': dicasPalavra,
    'segundos': segundos,
  };

  bool _certa(int i) {
    final certa = desafio.letra(i ~/ desafio.tamanho, i % desafio.tamanho);
    return certa != null && respostas[i] == certa;
  }

  void _revelar(int i) {
    respostas[i] = desafio.letra(i ~/ desafio.tamanho, i % desafio.tamanho)!;
    reveladas.add(i);
    erradas.remove(i);
  }

  void _selecionarPrimeira() {
    if (desafio.palavras.isEmpty) return;
    // Ao retomar, começa pela primeira palavra que ainda falta.
    final p = desafio.palavras.firstWhere(
      (q) => !palavraCompleta(q),
      orElse: () => desafio.palavras.first,
    );
    _irPara(p);
  }

  /// Vai para a próxima casa da palavra, pulando as travadas.
  void _avancar() {
    final p = palavraAtual;
    if (p == null) return;
    final posicao = p.casas.toList().indexOf((linha, coluna));
    for (var k = posicao + 1; k < p.tamanho; k++) {
      final (l, c) = p.casa(k);
      if (!travada(desafio.indice(l, c))) {
        linha = l;
        coluna = c;
        return;
      }
    }
  }

  void _voltar() {
    final p = palavraAtual;
    if (p == null) return;
    final posicao = p.casas.toList().indexOf((linha, coluna));
    for (var k = posicao - 1; k >= 0; k--) {
      final (l, c) = p.casa(k);
      if (!travada(desafio.indice(l, c))) {
        linha = l;
        coluna = c;
        return;
      }
    }
  }
}
