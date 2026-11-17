import 'dart:convert';
import 'dart:isolate';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/caca_palavras.dart';
import '../dominio/desafio.dart';
import '../dominio/jogo_caca.dart';
import '../dominio/jogo_cruzadas.dart';
import 'tela_caca.dart';
import 'tela_inicio.dart' show Modo;
import 'tela_jogo.dart';

/// Monta a grade fora da tela principal, para o app não travar.
Future<T> montarGrade<T>(T Function() montar) => Isolate.run(montar);

/// Cria a partida no banco e abre o jogo de cruzadas.
Future<void> comecarCruzadas(
  BuildContext context,
  int perfilId,
  DesafioCruzadas desafio,
) async {
  final jogo = JogoCruzadas(desafio);
  final partidaId = await Servicos.of(context).banco.iniciarPartida(
    perfilId: perfilId,
    modo: Modo.cruzadas.id,
    desafioId: desafio.id,
    desafio: jsonEncode(desafio.paraJson()),
    respostas: jsonEncode(jogo.paraJson()),
  );
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TelaJogo(jogo: jogo, partidaId: partidaId),
    ),
  );
}

/// Cria a partida no banco e abre o caça-palavras.
Future<void> comecarCaca(
  BuildContext context,
  int perfilId,
  DesafioCaca desafio,
) async {
  final jogo = JogoCaca(desafio);
  final partidaId = await Servicos.of(context).banco.iniciarPartida(
    perfilId: perfilId,
    modo: Modo.caca.id,
    desafioId: desafio.id,
    desafio: jsonEncode(desafio.paraJson()),
    respostas: jsonEncode(jogo.paraJson()),
  );
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TelaCaca(jogo: jogo, partidaId: partidaId),
    ),
  );
}

/// Continua uma partida salva (pendente ou do desafio do dia).
Future<void> retomarPartida(BuildContext context, Partida partida) {
  final Widget tela = Modo.daPartida(partida) == Modo.caca
      ? TelaCaca(jogo: jogoCacaDa(partida), partidaId: partida.id)
      : TelaJogo(jogo: jogoCruzadasDa(partida), partidaId: partida.id);
  return Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => tela));
}

JogoCruzadas jogoCruzadasDa(Partida partida) => JogoCruzadas.deJson(
  DesafioCruzadas.deJson(jsonDecode(partida.desafio) as Map<String, dynamic>),
  jsonDecode(partida.respostas) as Map<String, dynamic>,
);

JogoCaca jogoCacaDa(Partida partida) => JogoCaca.deJson(
  DesafioCaca.deJson(jsonDecode(partida.desafio) as Map<String, dynamic>),
  jsonDecode(partida.respostas) as Map<String, dynamic>,
);
