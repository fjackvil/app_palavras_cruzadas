import 'package:flutter/foundation.dart';

import 'caca_palavras.dart';
import 'nivel.dart';
import 'pontuacao.dart';

/// Estado de uma partida de caça-palavras. O banco guarda o que [paraJson]
/// devolve.
class JogoCaca extends ChangeNotifier {
  JogoCaca(
    this.desafio, {
    Set<int>? encontradas,
    Set<int>? comDica,
    this.segundos = 0,
  }) : encontradas = encontradas ?? <int>{},
       comDica = comDica ?? <int>{};

  factory JogoCaca.deJson(DesafioCaca desafio, Map<String, dynamic> json) =>
      JogoCaca(
        desafio,
        encontradas: Set<int>.from(json['encontradas'] as List),
        comDica: Set<int>.from(json['comDica'] as List),
        segundos: json['segundos'] as int? ?? 0,
      );

  final DesafioCaca desafio;

  /// Índices (em desafio.palavras) das palavras já achadas.
  final Set<int> encontradas;

  /// Palavras cuja primeira letra foi mostrada por dica.
  final Set<int> comDica;
  int segundos;

  /// Primeira casa da seleção feita com toques (toca na primeira letra e
  /// depois na última).
  (int, int)? inicioToque;

  Nivel get nivel => desafio.nivel;
  int get dicasUsadas => comDica.length;
  bool get concluido => encontradas.length == desafio.palavras.length;

  /// Casas entre dois pontos, se estão numa linha reta.
  List<(int, int)>? linhaEntre(int l1, int c1, int l2, int c2) {
    if (l1 == l2 && c1 == c2) return [(l1, c1)];
    final d = Direcao.entre(l1, c1, l2, c2);
    if (d == null) return null;
    final passos = (l2 - l1).abs() > (c2 - c1).abs()
        ? (l2 - l1).abs()
        : (c2 - c1).abs();
    return [for (var i = 0; i <= passos; i++) (l1 + d.dl * i, c1 + d.dc * i)];
  }

  /// Tenta achar uma palavra entre as duas casas (em qualquer sentido).
  /// Devolve o índice da palavra achada, ou null.
  int? tentar(int l1, int c1, int l2, int c2) {
    inicioToque = null;
    final casas = linhaEntre(l1, c1, l2, c2);
    if (casas == null || casas.length < 2 || concluido) {
      notifyListeners();
      return null;
    }
    final texto = casas.map((c) => desafio.letra(c.$1, c.$2)).join();
    final inverso = texto.split('').reversed.join();
    for (var i = 0; i < desafio.palavras.length; i++) {
      if (encontradas.contains(i)) continue;
      final p = desafio.palavras[i];
      if (p.resposta == texto || p.resposta == inverso) {
        encontradas.add(i);
        notifyListeners();
        return i;
      }
    }
    notifyListeners();
    return null;
  }

  /// Seleção por toques: o primeiro toque marca o início, o segundo tenta
  /// a palavra. Devolve o índice achado no segundo toque, ou null.
  int? tocar(int l, int c) {
    final inicio = inicioToque;
    if (inicio == null || inicio == (l, c)) {
      inicioToque = inicio == (l, c) ? null : (l, c);
      notifyListeners();
      return null;
    }
    return tentar(inicio.$1, inicio.$2, l, c);
  }

  /// Dica: mostra a primeira letra de uma palavra que falta. Devolve a
  /// palavra, ou null se não sobrou nenhuma sem dica.
  PalavraEscondida? dica() {
    for (var i = 0; i < desafio.palavras.length; i++) {
      if (encontradas.contains(i) || comDica.contains(i)) continue;
      comDica.add(i);
      notifyListeners();
      return desafio.palavras[i];
    }
    return null;
  }

  /// "Ver resposta": marca todas.
  void revelarTudo() {
    for (var i = 0; i < desafio.palavras.length; i++) {
      encontradas.add(i);
    }
    notifyListeners();
  }

  void contarSegundo() {
    segundos++;
    notifyListeners();
  }

  int get letrasAchadas =>
      encontradas.fold(0, (s, i) => s + desafio.palavras[i].tamanho);

  Pontuacao get pontuacao => Pontuacao.calcular(
    nivel: nivel,
    letras: letrasAchadas,
    segundos: segundos,
    tempoAlvoSegundos: desafio.tempoAlvoSegundos,
    dicasLetra: dicasUsadas,
    dicasPalavra: 0,
  );

  Map<String, dynamic> paraJson() => {
    'encontradas': encontradas.toList(),
    'comDica': comDica.toList(),
    'segundos': segundos,
  };
}
