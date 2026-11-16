import 'dart:convert';
import 'dart:io';

import 'package:palavras_cruzadas/dominio/tema.dart';

/// Lê os temas direto da pasta assets, sem precisar do Flutter.
List<Tema> temasDoDisco() {
  final arquivos =
      Directory('assets/palavras')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final f in arquivos)
      Tema.deJson(
        f.uri.pathSegments.last.replaceAll('.json', ''),
        jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
      ),
  ];
}
