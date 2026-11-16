import 'dart:convert';

import 'package:flutter/services.dart';

import 'nivel.dart';
import 'texto.dart';

/// Uma palavra do banco, com as dicas por nível.
class Palavra {
  Palavra({
    required this.palavra,
    required this.dificuldade,
    required this.dicas,
    required this.tema,
  }) : grade = paraGrade(palavra);

  factory Palavra.deJson(Map<String, dynamic> json, String tema) => Palavra(
    palavra: json['palavra'] as String,
    dificuldade: json['dificuldade'] as int,
    dicas: Map<String, String>.from(json['dicas'] as Map),
    tema: tema,
  );

  /// Como a palavra é escrita (com acentos), por exemplo "LEÃO".
  final String palavra;

  /// Como a palavra entra na grade, por exemplo "LEAO".
  final String grade;
  final int dificuldade;
  final Map<String, String> dicas;
  final String tema;

  /// Dica do nível; se faltar, usa a mais próxima.
  String dicaPara(Nivel nivel) {
    final ordem = nivel == Nivel.leve
        ? ['leve', 'media', 'dificil']
        : ['media', 'leve', 'dificil'];
    for (final chave in ordem) {
      final dica = dicas[chave];
      if (dica != null && dica.isNotEmpty) return dica;
    }
    return '';
  }
}

/// Um tema, carregado de um JSON em `assets/palavras/`.
class Tema {
  Tema({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.infantil,
    required this.premium,
    required this.palavras,
  });

  factory Tema.deJson(String id, Map<String, dynamic> json) {
    final nome = json['tema'] as String;
    return Tema(
      id: id,
      nome: nome,
      categoria: json['categoria'] as String,
      infantil: json['infantil'] as bool? ?? false,
      premium: json['premium'] as bool? ?? false,
      palavras: (json['palavras'] as List)
          .map((p) => Palavra.deJson(p as Map<String, dynamic>, nome))
          .toList(),
    );
  }

  final String id;
  final String nome;
  final String categoria;
  final bool infantil;
  final bool premium;
  final List<Palavra> palavras;

  /// Palavras que servem para o nível (dificuldade e tamanho).
  List<Palavra> palavrasPara(Nivel nivel) => palavras
      .where(
        (p) =>
            p.dificuldade <= nivel.maxDificuldade &&
            p.grade.length >= nivel.minLetras &&
            p.grade.length <= nivel.maxLetras,
      )
      .toList();
}

/// Lê os temas que vêm dentro do app.
class RepositorioTemas {
  RepositorioTemas({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<Tema>? _cache;

  Future<List<Tema>> carregar() async {
    if (_cache != null) return _cache!;
    final manifesto = await AssetManifest.loadFromAssetBundle(_bundle);
    final caminhos =
        manifesto
            .listAssets()
            .where(
              (c) => c.startsWith('assets/palavras/') && c.endsWith('.json'),
            )
            .toList()
          ..sort();
    final temas = <Tema>[];
    for (final caminho in caminhos) {
      final id = caminho.split('/').last.replaceAll('.json', '');
      final texto = await _bundle.loadString(caminho);
      temas.add(Tema.deJson(id, jsonDecode(texto) as Map<String, dynamic>));
    }
    temas.sort((a, b) => a.nome.compareTo(b.nome));
    return _cache = temas;
  }
}
