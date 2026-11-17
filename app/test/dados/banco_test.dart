import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palavras_cruzadas/widgets/avatar.dart';

void main() {
  late Banco banco;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    banco = Banco(NativeDatabase.memory());
  });
  tearDown(() => banco.close());

  Future<Perfil> novo(String nome) => banco.criarPerfil(
    nome: nome,
    anoNascimento: 2018,
    avatar: '🦁',
    nivel: 'leve',
  );

  test('cria até 5 perfis', () async {
    for (var i = 1; i <= 5; i++) {
      await novo('Jogador $i');
    }
    expect(await banco.listarPerfis(), hasLength(5));
    expect(() => novo('Sexto'), throwsStateError);
  });

  test('partida vai de andamento para desistido e concluído', () async {
    final perfil = await novo('Ana');
    final id = await banco.iniciarPartida(
      perfilId: perfil.id,
      modo: 'cruzadas',
      desafioId: 'x',
      desafio: '{}',
      respostas: '{}',
    );
    expect(await banco.observarPendentes(perfil.id).first, hasLength(1));

    await banco.salvarPartida(
      id,
      estado: EstadoPartida.desistido,
      respostas: '{}',
      tempoGastoSeg: 30,
      dicasUsadas: 1,
    );
    final pendente = (await banco.observarPendentes(perfil.id).first).single;
    expect(pendente.estado, EstadoPartida.desistido);
    expect(pendente.tempoGastoSeg, 30);

    await banco.salvarPartida(
      id,
      estado: EstadoPartida.concluido,
      respostas: '{}',
      tempoGastoSeg: 60,
      dicasUsadas: 1,
      pontos: 120,
    );
    expect(await banco.observarPendentes(perfil.id).first, isEmpty);
    expect(await banco.observarConcluidas(perfil.id).first, hasLength(1));
    expect(await banco.observarTotalPontos(perfil.id).first, 120);
  });

  test('apagar o perfil apaga as partidas dele', () async {
    final perfil = await novo('Bia');
    await banco.iniciarPartida(
      perfilId: perfil.id,
      modo: 'cruzadas',
      desafioId: 'x',
      desafio: '{}',
      respostas: '{}',
    );
    await banco.apagarPerfil(perfil.id);
    expect(await banco.select(banco.partidas).get(), isEmpty);
  });

  test('ver resposta encerra sem pontos e entra no histórico', () async {
    final perfil = await novo('Caio');
    final id = await banco.iniciarPartida(
      perfilId: perfil.id,
      modo: 'cruzadas',
      desafioId: 'x',
      desafio: '{}',
      respostas: '{}',
    );
    await banco.salvarPartida(
      id,
      estado: EstadoPartida.resposta,
      respostas: '{}',
      tempoGastoSeg: 40,
      dicasUsadas: 0,
    );
    expect(await banco.observarPendentes(perfil.id).first, isEmpty);
    expect(await banco.observarConcluidas(perfil.id).first, hasLength(1));
    expect(await banco.ultimasEncerradas(perfil.id), hasLength(1));
    expect(await banco.observarTotalPontos(perfil.id).first, 0);
  });

  test('trocar o avatar por uma foto', () async {
    final perfil = await novo('Duda');
    await banco.mudarAvatar(perfil.id, 'foto:/tmp/x.jpg');
    final lido = (await banco.listarPerfis()).single;
    expect(lido.avatar, 'foto:/tmp/x.jpg');
    expect(Avatar.ehFoto(lido.avatar), isTrue);
    expect(Avatar.caminho(lido.avatar), '/tmp/x.jpg');
    expect(Avatar.ehFoto('🦁'), isFalse);
  });

  test('placar lê só as concluídas', () async {
    final perfil = await novo('Eva');
    final a = await banco.iniciarPartida(
      perfilId: perfil.id,
      modo: 'cruzadas',
      desafioId: 'cruzadas:medio:animais:1',
      desafio: '{}',
      respostas: '{}',
    );
    await banco.iniciarPartida(
      perfilId: perfil.id,
      modo: 'cruzadas',
      desafioId: 'cruzadas:leve:frutas:2',
      desafio: '{}',
      respostas: '{}',
    );
    await banco.salvarPartida(
      a,
      estado: EstadoPartida.concluido,
      respostas: '{}',
      tempoGastoSeg: 30,
      dicasUsadas: 0,
      pontos: 42,
    );
    final registros = await banco.observarRegistrosPlacar().first;
    expect(registros, hasLength(1));
    expect(registros.single.pontos, 42);
    expect(registros.single.temas, ['animais']);
  });

  test('ajustes, dicas do dia e desafios do dia', () async {
    final perfil = await novo('Gil');
    final agora = DateTime.now();
    expect(await banco.lerAjuste('premium'), isNull);
    await banco.gravarAjuste('premium', '1');
    await banco.gravarAjuste('premium', '0');
    expect(await banco.lerAjuste('premium'), '0');

    expect(await banco.dicasHoje(perfil.id, agora), 0);
    await banco.contarDica(perfil.id, agora);
    await banco.contarDica(perfil.id, agora);
    expect(await banco.dicasHoje(perfil.id, agora), 2);
    final amanha = agora.add(const Duration(days: 1));
    expect(await banco.dicasHoje(perfil.id, amanha), 0);

    for (final id in [
      'cruzadas:leve:x:1',
      'caca:leve:x:2',
      'cruzadas:diario:leve:2026-11-17',
    ]) {
      await banco.iniciarPartida(
        perfilId: perfil.id,
        modo: 'cruzadas',
        desafioId: id,
        desafio: '{}',
        respostas: '{}',
      );
    }
    // O desafio do dia não conta no limite.
    expect(await banco.desafiosHoje(perfil.id, agora), 2);
  });

  test('banco da versão 1 é atualizado sem perder dados', () async {
    final pasta = Directory.systemTemp.createTempSync('banco_v1');
    final arquivo = File('${pasta.path}/v1.sqlite');
    final antigo = sqlite3.open(arquivo.path);
    antigo.execute('''
      CREATE TABLE perfis (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL,
        ano_nascimento INTEGER NOT NULL, avatar TEXT NOT NULL, nivel_atual TEXT NOT NULL,
        criado_em INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)));
      CREATE TABLE partidas (id INTEGER PRIMARY KEY AUTOINCREMENT,
        perfil_id INTEGER NOT NULL REFERENCES perfis (id) ON DELETE CASCADE,
        modo TEXT NOT NULL, desafio_id TEXT NOT NULL, desafio TEXT NOT NULL,
        estado TEXT NOT NULL, respostas TEXT NOT NULL,
        tempo_gasto_seg INTEGER NOT NULL DEFAULT 0, dicas_usadas INTEGER NOT NULL DEFAULT 0,
        pontos INTEGER NOT NULL DEFAULT 0,
        atualizado_em INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)));
      INSERT INTO perfis (nome, ano_nascimento, avatar, nivel_atual) VALUES ('Theo', 2018, 'x', 'leve');
      INSERT INTO partidas (perfil_id, modo, desafio_id, desafio, estado, respostas, pontos)
        VALUES (1, 'cruzadas', 'cruzadas:leve:x:1', '{}', 'concluido', '{}', 225);
      PRAGMA user_version = 1;
    ''');
    antigo.close();

    final atualizado = Banco(NativeDatabase(arquivo));
    expect((await atualizado.listarPerfis()).single.nome, 'Theo');
    expect(await atualizado.observarTotalPontos(1).first, 225);
    await atualizado.gravarAjuste('premium', '1');
    expect(await atualizado.lerAjuste('premium'), '1');
    expect(await atualizado.desafiosHoje(1, DateTime.now()), 0);
    await atualizado.close();
    pasta.deleteSync(recursive: true);
  });

  test(
    'pendentes livres não contam o desafio do dia; apagar partida',
    () async {
      final perfil = await novo('Rui');
      final ids = <int>[];
      for (final id in [
        'cruzadas:leve:x:1',
        'caca:leve:x:2',
        'cruzadas:diario:leve:2026-11-17',
      ]) {
        ids.add(
          await banco.iniciarPartida(
            perfilId: perfil.id,
            modo: 'cruzadas',
            desafioId: id,
            desafio: '{}',
            respostas: '{}',
          ),
        );
      }
      expect(await banco.pendentesLivres(perfil.id), 2);
      await banco.apagarPartida(ids.first);
      expect(await banco.pendentesLivres(perfil.id), 1);
    },
  );
}
