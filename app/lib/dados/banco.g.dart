// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $PerfisTable extends Perfis with TableInfo<$PerfisTable, Perfil> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PerfisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anoNascimentoMeta = const VerificationMeta(
    'anoNascimento',
  );
  @override
  late final GeneratedColumn<int> anoNascimento = GeneratedColumn<int>(
    'ano_nascimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelAtualMeta = const VerificationMeta(
    'nivelAtual',
  );
  @override
  late final GeneratedColumn<String> nivelAtual = GeneratedColumn<String>(
    'nivel_atual',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    anoNascimento,
    avatar,
    nivelAtual,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'perfis';
  @override
  VerificationContext validateIntegrity(
    Insertable<Perfil> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('ano_nascimento')) {
      context.handle(
        _anoNascimentoMeta,
        anoNascimento.isAcceptableOrUnknown(
          data['ano_nascimento']!,
          _anoNascimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anoNascimentoMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarMeta);
    }
    if (data.containsKey('nivel_atual')) {
      context.handle(
        _nivelAtualMeta,
        nivelAtual.isAcceptableOrUnknown(data['nivel_atual']!, _nivelAtualMeta),
      );
    } else if (isInserting) {
      context.missing(_nivelAtualMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Perfil map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Perfil(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      anoNascimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ano_nascimento'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      nivelAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_atual'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $PerfisTable createAlias(String alias) {
    return $PerfisTable(attachedDatabase, alias);
  }
}

class Perfil extends DataClass implements Insertable<Perfil> {
  final int id;
  final String nome;
  final int anoNascimento;
  final String avatar;

  /// Nome do enum Nivel ('leve', 'medio').
  final String nivelAtual;
  final DateTime criadoEm;
  const Perfil({
    required this.id,
    required this.nome,
    required this.anoNascimento,
    required this.avatar,
    required this.nivelAtual,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['ano_nascimento'] = Variable<int>(anoNascimento);
    map['avatar'] = Variable<String>(avatar);
    map['nivel_atual'] = Variable<String>(nivelAtual);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  PerfisCompanion toCompanion(bool nullToAbsent) {
    return PerfisCompanion(
      id: Value(id),
      nome: Value(nome),
      anoNascimento: Value(anoNascimento),
      avatar: Value(avatar),
      nivelAtual: Value(nivelAtual),
      criadoEm: Value(criadoEm),
    );
  }

  factory Perfil.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Perfil(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      anoNascimento: serializer.fromJson<int>(json['anoNascimento']),
      avatar: serializer.fromJson<String>(json['avatar']),
      nivelAtual: serializer.fromJson<String>(json['nivelAtual']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'anoNascimento': serializer.toJson<int>(anoNascimento),
      'avatar': serializer.toJson<String>(avatar),
      'nivelAtual': serializer.toJson<String>(nivelAtual),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  Perfil copyWith({
    int? id,
    String? nome,
    int? anoNascimento,
    String? avatar,
    String? nivelAtual,
    DateTime? criadoEm,
  }) => Perfil(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    anoNascimento: anoNascimento ?? this.anoNascimento,
    avatar: avatar ?? this.avatar,
    nivelAtual: nivelAtual ?? this.nivelAtual,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Perfil copyWithCompanion(PerfisCompanion data) {
    return Perfil(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      anoNascimento: data.anoNascimento.present
          ? data.anoNascimento.value
          : this.anoNascimento,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      nivelAtual: data.nivelAtual.present
          ? data.nivelAtual.value
          : this.nivelAtual,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Perfil(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('anoNascimento: $anoNascimento, ')
          ..write('avatar: $avatar, ')
          ..write('nivelAtual: $nivelAtual, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, anoNascimento, avatar, nivelAtual, criadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Perfil &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.anoNascimento == this.anoNascimento &&
          other.avatar == this.avatar &&
          other.nivelAtual == this.nivelAtual &&
          other.criadoEm == this.criadoEm);
}

class PerfisCompanion extends UpdateCompanion<Perfil> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> anoNascimento;
  final Value<String> avatar;
  final Value<String> nivelAtual;
  final Value<DateTime> criadoEm;
  const PerfisCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.anoNascimento = const Value.absent(),
    this.avatar = const Value.absent(),
    this.nivelAtual = const Value.absent(),
    this.criadoEm = const Value.absent(),
  });
  PerfisCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int anoNascimento,
    required String avatar,
    required String nivelAtual,
    this.criadoEm = const Value.absent(),
  }) : nome = Value(nome),
       anoNascimento = Value(anoNascimento),
       avatar = Value(avatar),
       nivelAtual = Value(nivelAtual);
  static Insertable<Perfil> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? anoNascimento,
    Expression<String>? avatar,
    Expression<String>? nivelAtual,
    Expression<DateTime>? criadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (anoNascimento != null) 'ano_nascimento': anoNascimento,
      if (avatar != null) 'avatar': avatar,
      if (nivelAtual != null) 'nivel_atual': nivelAtual,
      if (criadoEm != null) 'criado_em': criadoEm,
    });
  }

  PerfisCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? anoNascimento,
    Value<String>? avatar,
    Value<String>? nivelAtual,
    Value<DateTime>? criadoEm,
  }) {
    return PerfisCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      anoNascimento: anoNascimento ?? this.anoNascimento,
      avatar: avatar ?? this.avatar,
      nivelAtual: nivelAtual ?? this.nivelAtual,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (anoNascimento.present) {
      map['ano_nascimento'] = Variable<int>(anoNascimento.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (nivelAtual.present) {
      map['nivel_atual'] = Variable<String>(nivelAtual.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PerfisCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('anoNascimento: $anoNascimento, ')
          ..write('avatar: $avatar, ')
          ..write('nivelAtual: $nivelAtual, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }
}

class $PartidasTable extends Partidas with TableInfo<$PartidasTable, Partida> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartidasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _perfilIdMeta = const VerificationMeta(
    'perfilId',
  );
  @override
  late final GeneratedColumn<int> perfilId = GeneratedColumn<int>(
    'perfil_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES perfis (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modoMeta = const VerificationMeta('modo');
  @override
  late final GeneratedColumn<String> modo = GeneratedColumn<String>(
    'modo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _desafioIdMeta = const VerificationMeta(
    'desafioId',
  );
  @override
  late final GeneratedColumn<String> desafioId = GeneratedColumn<String>(
    'desafio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _desafioMeta = const VerificationMeta(
    'desafio',
  );
  @override
  late final GeneratedColumn<String> desafio = GeneratedColumn<String>(
    'desafio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respostasMeta = const VerificationMeta(
    'respostas',
  );
  @override
  late final GeneratedColumn<String> respostas = GeneratedColumn<String>(
    'respostas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempoGastoSegMeta = const VerificationMeta(
    'tempoGastoSeg',
  );
  @override
  late final GeneratedColumn<int> tempoGastoSeg = GeneratedColumn<int>(
    'tempo_gasto_seg',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dicasUsadasMeta = const VerificationMeta(
    'dicasUsadas',
  );
  @override
  late final GeneratedColumn<int> dicasUsadas = GeneratedColumn<int>(
    'dicas_usadas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pontosMeta = const VerificationMeta('pontos');
  @override
  late final GeneratedColumn<int> pontos = GeneratedColumn<int>(
    'pontos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    perfilId,
    modo,
    desafioId,
    desafio,
    estado,
    respostas,
    tempoGastoSeg,
    dicasUsadas,
    pontos,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partidas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Partida> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('perfil_id')) {
      context.handle(
        _perfilIdMeta,
        perfilId.isAcceptableOrUnknown(data['perfil_id']!, _perfilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_perfilIdMeta);
    }
    if (data.containsKey('modo')) {
      context.handle(
        _modoMeta,
        modo.isAcceptableOrUnknown(data['modo']!, _modoMeta),
      );
    } else if (isInserting) {
      context.missing(_modoMeta);
    }
    if (data.containsKey('desafio_id')) {
      context.handle(
        _desafioIdMeta,
        desafioId.isAcceptableOrUnknown(data['desafio_id']!, _desafioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_desafioIdMeta);
    }
    if (data.containsKey('desafio')) {
      context.handle(
        _desafioMeta,
        desafio.isAcceptableOrUnknown(data['desafio']!, _desafioMeta),
      );
    } else if (isInserting) {
      context.missing(_desafioMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('respostas')) {
      context.handle(
        _respostasMeta,
        respostas.isAcceptableOrUnknown(data['respostas']!, _respostasMeta),
      );
    } else if (isInserting) {
      context.missing(_respostasMeta);
    }
    if (data.containsKey('tempo_gasto_seg')) {
      context.handle(
        _tempoGastoSegMeta,
        tempoGastoSeg.isAcceptableOrUnknown(
          data['tempo_gasto_seg']!,
          _tempoGastoSegMeta,
        ),
      );
    }
    if (data.containsKey('dicas_usadas')) {
      context.handle(
        _dicasUsadasMeta,
        dicasUsadas.isAcceptableOrUnknown(
          data['dicas_usadas']!,
          _dicasUsadasMeta,
        ),
      );
    }
    if (data.containsKey('pontos')) {
      context.handle(
        _pontosMeta,
        pontos.isAcceptableOrUnknown(data['pontos']!, _pontosMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Partida map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Partida(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      perfilId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perfil_id'],
      )!,
      modo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modo'],
      )!,
      desafioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desafio_id'],
      )!,
      desafio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desafio'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      respostas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}respostas'],
      )!,
      tempoGastoSeg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tempo_gasto_seg'],
      )!,
      dicasUsadas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dicas_usadas'],
      )!,
      pontos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pontos'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $PartidasTable createAlias(String alias) {
    return $PartidasTable(attachedDatabase, alias);
  }
}

class Partida extends DataClass implements Insertable<Partida> {
  final int id;
  final int perfilId;

  /// 'cruzadas' ou 'caca_palavras' (fase 3).
  final String modo;
  final String desafioId;

  /// Grade completa em JSON, para retomar sem precisar gerar de novo.
  final String desafio;
  final String estado;

  /// Letras digitadas, dicas e tempo, em JSON.
  final String respostas;
  final int tempoGastoSeg;
  final int dicasUsadas;
  final int pontos;
  final DateTime atualizadoEm;
  const Partida({
    required this.id,
    required this.perfilId,
    required this.modo,
    required this.desafioId,
    required this.desafio,
    required this.estado,
    required this.respostas,
    required this.tempoGastoSeg,
    required this.dicasUsadas,
    required this.pontos,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['perfil_id'] = Variable<int>(perfilId);
    map['modo'] = Variable<String>(modo);
    map['desafio_id'] = Variable<String>(desafioId);
    map['desafio'] = Variable<String>(desafio);
    map['estado'] = Variable<String>(estado);
    map['respostas'] = Variable<String>(respostas);
    map['tempo_gasto_seg'] = Variable<int>(tempoGastoSeg);
    map['dicas_usadas'] = Variable<int>(dicasUsadas);
    map['pontos'] = Variable<int>(pontos);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  PartidasCompanion toCompanion(bool nullToAbsent) {
    return PartidasCompanion(
      id: Value(id),
      perfilId: Value(perfilId),
      modo: Value(modo),
      desafioId: Value(desafioId),
      desafio: Value(desafio),
      estado: Value(estado),
      respostas: Value(respostas),
      tempoGastoSeg: Value(tempoGastoSeg),
      dicasUsadas: Value(dicasUsadas),
      pontos: Value(pontos),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory Partida.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Partida(
      id: serializer.fromJson<int>(json['id']),
      perfilId: serializer.fromJson<int>(json['perfilId']),
      modo: serializer.fromJson<String>(json['modo']),
      desafioId: serializer.fromJson<String>(json['desafioId']),
      desafio: serializer.fromJson<String>(json['desafio']),
      estado: serializer.fromJson<String>(json['estado']),
      respostas: serializer.fromJson<String>(json['respostas']),
      tempoGastoSeg: serializer.fromJson<int>(json['tempoGastoSeg']),
      dicasUsadas: serializer.fromJson<int>(json['dicasUsadas']),
      pontos: serializer.fromJson<int>(json['pontos']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'perfilId': serializer.toJson<int>(perfilId),
      'modo': serializer.toJson<String>(modo),
      'desafioId': serializer.toJson<String>(desafioId),
      'desafio': serializer.toJson<String>(desafio),
      'estado': serializer.toJson<String>(estado),
      'respostas': serializer.toJson<String>(respostas),
      'tempoGastoSeg': serializer.toJson<int>(tempoGastoSeg),
      'dicasUsadas': serializer.toJson<int>(dicasUsadas),
      'pontos': serializer.toJson<int>(pontos),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  Partida copyWith({
    int? id,
    int? perfilId,
    String? modo,
    String? desafioId,
    String? desafio,
    String? estado,
    String? respostas,
    int? tempoGastoSeg,
    int? dicasUsadas,
    int? pontos,
    DateTime? atualizadoEm,
  }) => Partida(
    id: id ?? this.id,
    perfilId: perfilId ?? this.perfilId,
    modo: modo ?? this.modo,
    desafioId: desafioId ?? this.desafioId,
    desafio: desafio ?? this.desafio,
    estado: estado ?? this.estado,
    respostas: respostas ?? this.respostas,
    tempoGastoSeg: tempoGastoSeg ?? this.tempoGastoSeg,
    dicasUsadas: dicasUsadas ?? this.dicasUsadas,
    pontos: pontos ?? this.pontos,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  Partida copyWithCompanion(PartidasCompanion data) {
    return Partida(
      id: data.id.present ? data.id.value : this.id,
      perfilId: data.perfilId.present ? data.perfilId.value : this.perfilId,
      modo: data.modo.present ? data.modo.value : this.modo,
      desafioId: data.desafioId.present ? data.desafioId.value : this.desafioId,
      desafio: data.desafio.present ? data.desafio.value : this.desafio,
      estado: data.estado.present ? data.estado.value : this.estado,
      respostas: data.respostas.present ? data.respostas.value : this.respostas,
      tempoGastoSeg: data.tempoGastoSeg.present
          ? data.tempoGastoSeg.value
          : this.tempoGastoSeg,
      dicasUsadas: data.dicasUsadas.present
          ? data.dicasUsadas.value
          : this.dicasUsadas,
      pontos: data.pontos.present ? data.pontos.value : this.pontos,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Partida(')
          ..write('id: $id, ')
          ..write('perfilId: $perfilId, ')
          ..write('modo: $modo, ')
          ..write('desafioId: $desafioId, ')
          ..write('desafio: $desafio, ')
          ..write('estado: $estado, ')
          ..write('respostas: $respostas, ')
          ..write('tempoGastoSeg: $tempoGastoSeg, ')
          ..write('dicasUsadas: $dicasUsadas, ')
          ..write('pontos: $pontos, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    perfilId,
    modo,
    desafioId,
    desafio,
    estado,
    respostas,
    tempoGastoSeg,
    dicasUsadas,
    pontos,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Partida &&
          other.id == this.id &&
          other.perfilId == this.perfilId &&
          other.modo == this.modo &&
          other.desafioId == this.desafioId &&
          other.desafio == this.desafio &&
          other.estado == this.estado &&
          other.respostas == this.respostas &&
          other.tempoGastoSeg == this.tempoGastoSeg &&
          other.dicasUsadas == this.dicasUsadas &&
          other.pontos == this.pontos &&
          other.atualizadoEm == this.atualizadoEm);
}

class PartidasCompanion extends UpdateCompanion<Partida> {
  final Value<int> id;
  final Value<int> perfilId;
  final Value<String> modo;
  final Value<String> desafioId;
  final Value<String> desafio;
  final Value<String> estado;
  final Value<String> respostas;
  final Value<int> tempoGastoSeg;
  final Value<int> dicasUsadas;
  final Value<int> pontos;
  final Value<DateTime> atualizadoEm;
  const PartidasCompanion({
    this.id = const Value.absent(),
    this.perfilId = const Value.absent(),
    this.modo = const Value.absent(),
    this.desafioId = const Value.absent(),
    this.desafio = const Value.absent(),
    this.estado = const Value.absent(),
    this.respostas = const Value.absent(),
    this.tempoGastoSeg = const Value.absent(),
    this.dicasUsadas = const Value.absent(),
    this.pontos = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  PartidasCompanion.insert({
    this.id = const Value.absent(),
    required int perfilId,
    required String modo,
    required String desafioId,
    required String desafio,
    required String estado,
    required String respostas,
    this.tempoGastoSeg = const Value.absent(),
    this.dicasUsadas = const Value.absent(),
    this.pontos = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  }) : perfilId = Value(perfilId),
       modo = Value(modo),
       desafioId = Value(desafioId),
       desafio = Value(desafio),
       estado = Value(estado),
       respostas = Value(respostas);
  static Insertable<Partida> custom({
    Expression<int>? id,
    Expression<int>? perfilId,
    Expression<String>? modo,
    Expression<String>? desafioId,
    Expression<String>? desafio,
    Expression<String>? estado,
    Expression<String>? respostas,
    Expression<int>? tempoGastoSeg,
    Expression<int>? dicasUsadas,
    Expression<int>? pontos,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (perfilId != null) 'perfil_id': perfilId,
      if (modo != null) 'modo': modo,
      if (desafioId != null) 'desafio_id': desafioId,
      if (desafio != null) 'desafio': desafio,
      if (estado != null) 'estado': estado,
      if (respostas != null) 'respostas': respostas,
      if (tempoGastoSeg != null) 'tempo_gasto_seg': tempoGastoSeg,
      if (dicasUsadas != null) 'dicas_usadas': dicasUsadas,
      if (pontos != null) 'pontos': pontos,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  PartidasCompanion copyWith({
    Value<int>? id,
    Value<int>? perfilId,
    Value<String>? modo,
    Value<String>? desafioId,
    Value<String>? desafio,
    Value<String>? estado,
    Value<String>? respostas,
    Value<int>? tempoGastoSeg,
    Value<int>? dicasUsadas,
    Value<int>? pontos,
    Value<DateTime>? atualizadoEm,
  }) {
    return PartidasCompanion(
      id: id ?? this.id,
      perfilId: perfilId ?? this.perfilId,
      modo: modo ?? this.modo,
      desafioId: desafioId ?? this.desafioId,
      desafio: desafio ?? this.desafio,
      estado: estado ?? this.estado,
      respostas: respostas ?? this.respostas,
      tempoGastoSeg: tempoGastoSeg ?? this.tempoGastoSeg,
      dicasUsadas: dicasUsadas ?? this.dicasUsadas,
      pontos: pontos ?? this.pontos,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (perfilId.present) {
      map['perfil_id'] = Variable<int>(perfilId.value);
    }
    if (modo.present) {
      map['modo'] = Variable<String>(modo.value);
    }
    if (desafioId.present) {
      map['desafio_id'] = Variable<String>(desafioId.value);
    }
    if (desafio.present) {
      map['desafio'] = Variable<String>(desafio.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (respostas.present) {
      map['respostas'] = Variable<String>(respostas.value);
    }
    if (tempoGastoSeg.present) {
      map['tempo_gasto_seg'] = Variable<int>(tempoGastoSeg.value);
    }
    if (dicasUsadas.present) {
      map['dicas_usadas'] = Variable<int>(dicasUsadas.value);
    }
    if (pontos.present) {
      map['pontos'] = Variable<int>(pontos.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartidasCompanion(')
          ..write('id: $id, ')
          ..write('perfilId: $perfilId, ')
          ..write('modo: $modo, ')
          ..write('desafioId: $desafioId, ')
          ..write('desafio: $desafio, ')
          ..write('estado: $estado, ')
          ..write('respostas: $respostas, ')
          ..write('tempoGastoSeg: $tempoGastoSeg, ')
          ..write('dicasUsadas: $dicasUsadas, ')
          ..write('pontos: $pontos, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

abstract class _$Banco extends GeneratedDatabase {
  _$Banco(QueryExecutor e) : super(e);
  $BancoManager get managers => $BancoManager(this);
  late final $PerfisTable perfis = $PerfisTable(this);
  late final $PartidasTable partidas = $PartidasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [perfis, partidas];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'perfis',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('partidas', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PerfisTableCreateCompanionBuilder = PerfisCompanion Function({
  Value<int> id,
  required String nome,
  required int anoNascimento,
  required String avatar,
  required String nivelAtual,
  Value<DateTime> criadoEm,
});
typedef $$PerfisTableUpdateCompanionBuilder = PerfisCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> anoNascimento,
  Value<String> avatar,
  Value<String> nivelAtual,
  Value<DateTime> criadoEm,
});

final class $$PerfisTableReferences
    extends BaseReferences<_$Banco, $PerfisTable, Perfil> {
  $$PerfisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PartidasTable, List<Partida>> _partidasRefsTable(
    _$Banco db,
  ) => MultiTypedResultKey.fromTable(
    db.partidas,
    aliasName: 'perfis__id__partidas__perfil_id',
  );

  $$PartidasTableProcessedTableManager get partidasRefs {
    final manager = $$PartidasTableTableManager(
      $_db,
      $_db.partidas,
    ).filter((f) => f.perfilId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partidasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PerfisTableFilterComposer extends Composer<_$Banco, $PerfisTable> {
  $$PerfisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anoNascimento => $composableBuilder(
    column: $table.anoNascimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelAtual => $composableBuilder(
    column: $table.nivelAtual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> partidasRefs(
    Expression<bool> Function($$PartidasTableFilterComposer f) f,
  ) {
    final $$PartidasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partidas,
      getReferencedColumn: (t) => t.perfilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartidasTableFilterComposer(
            $db: $db,
            $table: $db.partidas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PerfisTableOrderingComposer extends Composer<_$Banco, $PerfisTable> {
  $$PerfisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anoNascimento => $composableBuilder(
    column: $table.anoNascimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelAtual => $composableBuilder(
    column: $table.nivelAtual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PerfisTableAnnotationComposer extends Composer<_$Banco, $PerfisTable> {
  $$PerfisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get anoNascimento => $composableBuilder(
    column: $table.anoNascimento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get nivelAtual => $composableBuilder(
    column: $table.nivelAtual,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  Expression<T> partidasRefs<T extends Object>(
    Expression<T> Function($$PartidasTableAnnotationComposer a) f,
  ) {
    final $$PartidasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partidas,
      getReferencedColumn: (t) => t.perfilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartidasTableAnnotationComposer(
            $db: $db,
            $table: $db.partidas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PerfisTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $PerfisTable,
          Perfil,
          $$PerfisTableFilterComposer,
          $$PerfisTableOrderingComposer,
          $$PerfisTableAnnotationComposer,
          $$PerfisTableCreateCompanionBuilder,
          $$PerfisTableUpdateCompanionBuilder,
          (Perfil, $$PerfisTableReferences),
          Perfil,
          PrefetchHooks Function({bool partidasRefs})
        > {
  $$PerfisTableTableManager(_$Banco db, $PerfisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PerfisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PerfisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PerfisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> anoNascimento = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<String> nivelAtual = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
              }) => PerfisCompanion(
                id: id,
                nome: nome,
                anoNascimento: anoNascimento,
                avatar: avatar,
                nivelAtual: nivelAtual,
                criadoEm: criadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required int anoNascimento,
                required String avatar,
                required String nivelAtual,
                Value<DateTime> criadoEm = const Value.absent(),
              }) => PerfisCompanion.insert(
                id: id,
                nome: nome,
                anoNascimento: anoNascimento,
                avatar: avatar,
                nivelAtual: nivelAtual,
                criadoEm: criadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PerfisTable, Perfil>(table),
                  $$PerfisTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({partidasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (partidasRefs) db.partidas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (partidasRefs)
                    await $_getPrefetchedDataByColumns<
                      Perfil,
                      $PerfisTable,
                      Partida,
                      $PartidasTable
                    >(
                      currentTable: table,
                      referencedTable: $$PerfisTableReferences
                          ._partidasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PerfisTableReferences(db, table, p0).partidasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'perfil_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PerfisTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $PerfisTable,
      Perfil,
      $$PerfisTableFilterComposer,
      $$PerfisTableOrderingComposer,
      $$PerfisTableAnnotationComposer,
      $$PerfisTableCreateCompanionBuilder,
      $$PerfisTableUpdateCompanionBuilder,
      (Perfil, $$PerfisTableReferences),
      Perfil,
      PrefetchHooks Function({bool partidasRefs})
    >;
typedef $$PartidasTableCreateCompanionBuilder = PartidasCompanion Function({
  Value<int> id,
  required int perfilId,
  required String modo,
  required String desafioId,
  required String desafio,
  required String estado,
  required String respostas,
  Value<int> tempoGastoSeg,
  Value<int> dicasUsadas,
  Value<int> pontos,
  Value<DateTime> atualizadoEm,
});
typedef $$PartidasTableUpdateCompanionBuilder = PartidasCompanion Function({
  Value<int> id,
  Value<int> perfilId,
  Value<String> modo,
  Value<String> desafioId,
  Value<String> desafio,
  Value<String> estado,
  Value<String> respostas,
  Value<int> tempoGastoSeg,
  Value<int> dicasUsadas,
  Value<int> pontos,
  Value<DateTime> atualizadoEm,
});

final class $$PartidasTableReferences
    extends BaseReferences<_$Banco, $PartidasTable, Partida> {
  $$PartidasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PerfisTable _perfilIdTable(_$Banco db) =>
      db.perfis.createAlias('partidas__perfil_id__perfis__id');

  $$PerfisTableProcessedTableManager get perfilId {
    final $_column = $_itemColumn<int>('perfil_id')!;

    final manager = $$PerfisTableTableManager(
      $_db,
      $_db.perfis,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_perfilIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PartidasTableFilterComposer extends Composer<_$Banco, $PartidasTable> {
  $$PartidasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modo => $composableBuilder(
    column: $table.modo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desafioId => $composableBuilder(
    column: $table.desafioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desafio => $composableBuilder(
    column: $table.desafio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get respostas => $composableBuilder(
    column: $table.respostas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tempoGastoSeg => $composableBuilder(
    column: $table.tempoGastoSeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dicasUsadas => $composableBuilder(
    column: $table.dicasUsadas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pontos => $composableBuilder(
    column: $table.pontos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$PerfisTableFilterComposer get perfilId {
    final $$PerfisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.perfilId,
      referencedTable: $db.perfis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PerfisTableFilterComposer(
            $db: $db,
            $table: $db.perfis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartidasTableOrderingComposer
    extends Composer<_$Banco, $PartidasTable> {
  $$PartidasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modo => $composableBuilder(
    column: $table.modo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desafioId => $composableBuilder(
    column: $table.desafioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desafio => $composableBuilder(
    column: $table.desafio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respostas => $composableBuilder(
    column: $table.respostas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tempoGastoSeg => $composableBuilder(
    column: $table.tempoGastoSeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dicasUsadas => $composableBuilder(
    column: $table.dicasUsadas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pontos => $composableBuilder(
    column: $table.pontos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$PerfisTableOrderingComposer get perfilId {
    final $$PerfisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.perfilId,
      referencedTable: $db.perfis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PerfisTableOrderingComposer(
            $db: $db,
            $table: $db.perfis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartidasTableAnnotationComposer
    extends Composer<_$Banco, $PartidasTable> {
  $$PartidasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modo =>
      $composableBuilder(column: $table.modo, builder: (column) => column);

  GeneratedColumn<String> get desafioId =>
      $composableBuilder(column: $table.desafioId, builder: (column) => column);

  GeneratedColumn<String> get desafio =>
      $composableBuilder(column: $table.desafio, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get respostas =>
      $composableBuilder(column: $table.respostas, builder: (column) => column);

  GeneratedColumn<int> get tempoGastoSeg => $composableBuilder(
    column: $table.tempoGastoSeg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dicasUsadas => $composableBuilder(
    column: $table.dicasUsadas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pontos =>
      $composableBuilder(column: $table.pontos, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  $$PerfisTableAnnotationComposer get perfilId {
    final $$PerfisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.perfilId,
      referencedTable: $db.perfis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PerfisTableAnnotationComposer(
            $db: $db,
            $table: $db.perfis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartidasTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $PartidasTable,
          Partida,
          $$PartidasTableFilterComposer,
          $$PartidasTableOrderingComposer,
          $$PartidasTableAnnotationComposer,
          $$PartidasTableCreateCompanionBuilder,
          $$PartidasTableUpdateCompanionBuilder,
          (Partida, $$PartidasTableReferences),
          Partida,
          PrefetchHooks Function({bool perfilId})
        > {
  $$PartidasTableTableManager(_$Banco db, $PartidasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartidasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartidasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartidasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> perfilId = const Value.absent(),
                Value<String> modo = const Value.absent(),
                Value<String> desafioId = const Value.absent(),
                Value<String> desafio = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> respostas = const Value.absent(),
                Value<int> tempoGastoSeg = const Value.absent(),
                Value<int> dicasUsadas = const Value.absent(),
                Value<int> pontos = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => PartidasCompanion(
                id: id,
                perfilId: perfilId,
                modo: modo,
                desafioId: desafioId,
                desafio: desafio,
                estado: estado,
                respostas: respostas,
                tempoGastoSeg: tempoGastoSeg,
                dicasUsadas: dicasUsadas,
                pontos: pontos,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int perfilId,
                required String modo,
                required String desafioId,
                required String desafio,
                required String estado,
                required String respostas,
                Value<int> tempoGastoSeg = const Value.absent(),
                Value<int> dicasUsadas = const Value.absent(),
                Value<int> pontos = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => PartidasCompanion.insert(
                id: id,
                perfilId: perfilId,
                modo: modo,
                desafioId: desafioId,
                desafio: desafio,
                estado: estado,
                respostas: respostas,
                tempoGastoSeg: tempoGastoSeg,
                dicasUsadas: dicasUsadas,
                pontos: pontos,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PartidasTable, Partida>(table),
                  $$PartidasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({perfilId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (perfilId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.perfilId,
                        referencedTable: $$PartidasTableReferences
                            ._perfilIdTable(db),
                        referencedColumn: $$PartidasTableReferences
                            ._perfilIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PartidasTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $PartidasTable,
      Partida,
      $$PartidasTableFilterComposer,
      $$PartidasTableOrderingComposer,
      $$PartidasTableAnnotationComposer,
      $$PartidasTableCreateCompanionBuilder,
      $$PartidasTableUpdateCompanionBuilder,
      (Partida, $$PartidasTableReferences),
      Partida,
      PrefetchHooks Function({bool perfilId})
    >;

class $BancoManager {
  final _$Banco _db;
  $BancoManager(this._db);
  $$PerfisTableTableManager get perfis =>
      $$PerfisTableTableManager(_db, _db.perfis);
  $$PartidasTableTableManager get partidas =>
      $$PartidasTableTableManager(_db, _db.partidas);
}
