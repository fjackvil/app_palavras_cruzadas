import 'dart:convert';

import '../dominio/caca_palavras.dart';
import '../dominio/desafio.dart';
import '../dominio/nivel.dart';
import '../dominio/recordes.dart';
import '../dominio/subir_nivel.dart';
import 'banco.dart';

/// Depois de concluir, confere se a pessoa fez 3 desafios seguidos rápido e
/// sem dicas no mesmo modo. Devolve o perfil e o nível a oferecer (ou null).
/// Se algo der errado aqui, só não oferece: o resultado aparece igual.
Future<(int?, Nivel?)> ofertaDeNivel(Banco banco, int partidaId) async {
  try {
    final partida = await banco.buscarPartida(partidaId);
    final perfil = await banco.buscarPerfil(partida.perfilId);
    final recentes = await banco.ultimasEncerradas(perfil.id);
    final resumos = [
      for (final p in recentes)
        if (p.modo == partida.modo) resumirPartida(p),
    ];
    return (
      perfil.id,
      SubirNivel.oferta(resumos, Nivel.porNome(perfil.nivelAtual)),
    );
  } on Object {
    return (null, null);
  }
}

ResumoPartida resumirPartida(Partida p) {
  final json = jsonDecode(p.desafio) as Map<String, dynamic>;
  final (nivel, alvo) = p.modo == DesafioCaca.modo
      ? (
          DesafioCaca.deJson(json).nivel,
          DesafioCaca.deJson(json).tempoAlvoSegundos,
        )
      : (
          DesafioCruzadas.deJson(json).nivel,
          DesafioCruzadas.deJson(json).tempoAlvoSegundos,
        );
  return ResumoPartida(
    nivel: nivel,
    concluida: p.estado == EstadoPartida.concluido,
    dicas: p.dicasUsadas,
    segundos: p.tempoGastoSeg,
    tempoAlvoSegundos: alvo,
  );
}

/// Recordes que o desafio [partidaId] (já salvo como concluído) bateu:
/// "Maior pontuação", "Melhor tempo". Se algo der errado, devolve vazio.
Future<List<String>> recordesBatidos(Banco banco, int partidaId) async {
  try {
    final todos = await banco.observarRegistrosPlacar().first;
    final novo = todos.firstWhere((r) => r.partidaId == partidaId);
    return Recordes.batidos(
      novo,
      todos.where((r) => r.perfilId == novo.perfilId).toList(),
    );
  } on Object {
    return const [];
  }
}
