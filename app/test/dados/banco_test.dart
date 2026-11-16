import 'package:palavras_cruzadas/dados/banco.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
