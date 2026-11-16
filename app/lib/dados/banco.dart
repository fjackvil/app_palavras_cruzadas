import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'banco.g.dart';

/// Jogadores do aparelho (até 5). Nada daqui sai do celular.
@DataClassName('Perfil')
class Perfis extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 30)();
  IntColumn get anoNascimento => integer()();
  TextColumn get avatar => text()();

  /// Nome do enum Nivel ('leve', 'medio').
  TextColumn get nivelAtual => text()();
  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();
}

/// Estados de uma partida, como na especificação.
abstract final class EstadoPartida {
  static const andamento = 'andamento';
  static const desistido = 'desistido';
  static const concluido = 'concluido';
}

/// Progresso, pendentes e histórico.
class Partidas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get perfilId =>
      integer().references(Perfis, #id, onDelete: KeyAction.cascade)();

  /// 'cruzadas' ou 'caca_palavras' (fase 3).
  TextColumn get modo => text()();
  TextColumn get desafioId => text()();

  /// Grade completa em JSON, para retomar sem precisar gerar de novo.
  TextColumn get desafio => text()();
  TextColumn get estado => text()();

  /// Letras digitadas, dicas e tempo, em JSON.
  TextColumn get respostas => text()();
  IntColumn get tempoGastoSeg => integer().withDefault(const Constant(0))();
  IntColumn get dicasUsadas => integer().withDefault(const Constant(0))();
  IntColumn get pontos => integer().withDefault(const Constant(0))();
  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Perfis, Partidas])
class Banco extends _$Banco {
  Banco([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'cruzaletra'));

  static const maxPerfis = 5;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );

  // ---------- Perfis ----------

  Stream<List<Perfil>> observarPerfis() => (select(
    perfis,
  )..orderBy([(p) => OrderingTerm(expression: p.id)])).watch();

  Future<List<Perfil>> listarPerfis() =>
      (select(perfis)..orderBy([(p) => OrderingTerm(expression: p.id)])).get();

  Future<Perfil> criarPerfil({
    required String nome,
    required int anoNascimento,
    required String avatar,
    required String nivel,
  }) async {
    final total = await perfis.count().getSingle();
    if (total >= maxPerfis) {
      throw StateError('Limite de $maxPerfis jogadores neste aparelho.');
    }
    final id = await into(perfis).insert(
      PerfisCompanion.insert(
        nome: nome.trim(),
        anoNascimento: anoNascimento,
        avatar: avatar,
        nivelAtual: nivel,
      ),
    );
    return (select(perfis)..where((p) => p.id.equals(id))).getSingle();
  }

  Future<void> mudarNivel(int perfilId, String nivel) =>
      (update(perfis)..where((p) => p.id.equals(perfilId))).write(
        PerfisCompanion(nivelAtual: Value(nivel)),
      );

  Future<void> apagarPerfil(int perfilId) =>
      (delete(perfis)..where((p) => p.id.equals(perfilId))).go();

  // ---------- Partidas ----------

  Future<int> iniciarPartida({
    required int perfilId,
    required String modo,
    required String desafioId,
    required String desafio,
    required String respostas,
  }) => into(partidas).insert(
    PartidasCompanion.insert(
      perfilId: perfilId,
      modo: modo,
      desafioId: desafioId,
      desafio: desafio,
      estado: EstadoPartida.andamento,
      respostas: respostas,
    ),
  );

  /// Salvamento automático, chamado a cada letra.
  Future<void> salvarPartida(
    int partidaId, {
    required String estado,
    required String respostas,
    required int tempoGastoSeg,
    required int dicasUsadas,
    int pontos = 0,
  }) => (update(partidas)..where((p) => p.id.equals(partidaId))).write(
    PartidasCompanion(
      estado: Value(estado),
      respostas: Value(respostas),
      tempoGastoSeg: Value(tempoGastoSeg),
      dicasUsadas: Value(dicasUsadas),
      pontos: Value(pontos),
      atualizadoEm: Value(DateTime.now()),
    ),
  );

  Future<Partida> buscarPartida(int partidaId) =>
      (select(partidas)..where((p) => p.id.equals(partidaId))).getSingle();

  /// Partidas desistidas ou largadas no meio, mais recentes primeiro.
  Stream<List<Partida>> observarPendentes(int perfilId) =>
      (select(partidas)
            ..where(
              (p) =>
                  p.perfilId.equals(perfilId) &
                  p.estado.isIn([
                    EstadoPartida.andamento,
                    EstadoPartida.desistido,
                  ]),
            )
            ..orderBy([
              (p) => OrderingTerm(
                expression: p.atualizadoEm,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  /// Histórico de concluídas, mais recentes primeiro.
  Stream<List<Partida>> observarConcluidas(int perfilId) =>
      (select(partidas)
            ..where(
              (p) =>
                  p.perfilId.equals(perfilId) &
                  p.estado.equals(EstadoPartida.concluido),
            )
            ..orderBy([
              (p) => OrderingTerm(
                expression: p.atualizadoEm,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  /// Partida mais recente do perfil com aquele desafio (ex.: o diário).
  Stream<Partida?> observarPartidaDoDesafio(int perfilId, String desafioId) =>
      (select(partidas)
            ..where(
              (p) =>
                  p.perfilId.equals(perfilId) & p.desafioId.equals(desafioId),
            )
            ..orderBy([
              (p) => OrderingTerm(
                expression: p.atualizadoEm,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .watchSingleOrNull();

  /// Datas ('2026-11-16') dos desafios diários concluídos pelo perfil.
  Stream<Set<String>> observarDiasDoDiario(int perfilId) =>
      (select(partidas)..where(
            (p) =>
                p.perfilId.equals(perfilId) &
                p.estado.equals(EstadoPartida.concluido) &
                p.desafioId.like('cruzadas:diario:%'),
          ))
          .watch()
          .map((lista) => {for (final p in lista) p.desafioId.split(':').last});

  /// Soma dos pontos das partidas concluídas do perfil.
  Stream<int> observarTotalPontos(int perfilId) {
    final soma = partidas.pontos.sum();
    final consulta = selectOnly(partidas)
      ..addColumns([soma])
      ..where(
        partidas.perfilId.equals(perfilId) &
            partidas.estado.equals(EstadoPartida.concluido),
      );
    return consulta.map((linha) => linha.read(soma) ?? 0).watchSingle();
  }
}
