import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/caca_palavras.dart';
import '../dominio/desafio.dart';
import '../dominio/desafio_diario.dart';
import '../dominio/gerador_cruzadas.dart';
import '../dominio/jogo_caca.dart';
import '../dominio/jogo_cruzadas.dart';
import '../dominio/nivel.dart';
import '../dominio/tema.dart';
import '../widgets/avatar.dart';
import 'tela_caca.dart';
import 'tela_como_jogar.dart';
import 'tela_conquistas.dart';
import 'tela_jogo.dart';
import 'tela_placar.dart';
import 'tela_recordes.dart';
import 'tela_resposta.dart';
import 'tela_resposta_caca.dart';

/// Abaixo desta idade o perfil só vê temas marcados como infantis.
const idadeTemasAdultos = 14;

/// Ordem das categorias na tela, como na especificação.
const ordemCategorias = [
  'Mundo',
  'Natureza',
  'Comida',
  'Cinema e TV',
  'Música',
  'História',
  'Ciência',
  'Esportes',
  'Cultura',
  'Dia a dia',
  'Língua portuguesa',
  'Atualidades',
];

/// Tela principal de um jogador: desafio do dia, nível, temas, pendentes e
/// histórico.
class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key, required this.perfilId, this.modoInicial});

  final int perfilId;

  /// Jogo já escolhido ao abrir (pelos cartões da primeira tela).
  final Modo? modoInicial;

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

/// Os dois modos de jogo.
enum Modo {
  cruzadas('cruzadas', 'Cruzadas', Icons.grid_on),
  caca(DesafioCaca.modo, 'Caça-palavras', Icons.search);

  const Modo(this.id, this.nome, this.icone);

  /// Como fica gravado na coluna `modo` das partidas.
  final String id;
  final String nome;
  final IconData icone;

  static Modo daPartida(Partida p) =>
      p.modo == DesafioCaca.modo ? Modo.caca : Modo.cruzadas;
}

class _TelaInicioState extends State<TelaInicio> {
  /// Ids dos temas escolhidos. Vazio = "Misturado".
  final Set<String> _escolhidos = {};
  Future<List<Tema>>? _temas;
  bool _montando = false;
  late Modo _modo = widget.modoInicial ?? Modo.cruzadas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _temas ??= Servicos.of(context).temas.carregar();
  }

  /// Temas que o perfil pode ver no nível: os infantis para crianças e só
  /// os que têm palavras suficientes para o modo e o nível.
  List<Tema> _visiveis(Perfil perfil, List<Tema> todos, Nivel nivel) {
    final idade = DateTime.now().year - perfil.anoNascimento;
    return todos
        .where((t) => idade >= idadeTemasAdultos || t.infantil)
        .where(
          (t) => _modo == Modo.caca
              ? temaServeParaCaca(t, nivel)
              : t.disponivelPara(nivel),
        )
        .toList();
  }

  /// Monta a grade fora da tela principal para o app não travar.
  Future<T> _montar<T>(T Function() montar) async {
    setState(() => _montando = true);
    try {
      return await Isolate.run(montar);
    } finally {
      if (mounted) setState(() => _montando = false);
    }
  }

  Future<void> _comecarCruzadas(Perfil perfil, DesafioCruzadas desafio) async {
    final jogo = JogoCruzadas(desafio);
    final partidaId = await Servicos.of(context).banco.iniciarPartida(
      perfilId: perfil.id,
      modo: Modo.cruzadas.id,
      desafioId: desafio.id,
      desafio: jsonEncode(desafio.paraJson()),
      respostas: jsonEncode(jogo.paraJson()),
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaJogo(jogo: jogo, partidaId: partidaId),
      ),
    );
  }

  Future<void> _comecarCaca(Perfil perfil, DesafioCaca desafio) async {
    final jogo = JogoCaca(desafio);
    final partidaId = await Servicos.of(context).banco.iniciarPartida(
      perfilId: perfil.id,
      modo: Modo.caca.id,
      desafioId: desafio.id,
      desafio: jsonEncode(desafio.paraJson()),
      respostas: jsonEncode(jogo.paraJson()),
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaCaca(jogo: jogo, partidaId: partidaId),
      ),
    );
  }

  Future<void> _jogar(Perfil perfil, List<Tema> visiveis, Nivel nivel) async {
    if (_montando) return;
    final escolhidos = visiveis
        .where((t) => _escolhidos.contains(t.id))
        .toList();
    final temas = escolhidos.isEmpty ? visiveis : escolhidos;
    final semente = Random().nextInt(1 << 31);
    if (_modo == Modo.caca) {
      final desafio = await _montar(tarefaCaca(temas, nivel, semente));
      await _comecarCaca(perfil, desafio);
    } else {
      final desafio = await _montar(tarefaCruzadas(temas, nivel, semente));
      await _comecarCruzadas(perfil, desafio);
    }
  }

  Future<void> _jogarDiario(
    Perfil perfil,
    List<Tema> todos,
    Nivel nivel,
    Modo modo,
  ) async {
    if (_montando) return;
    final hoje = DateTime.now();
    if (modo == Modo.caca) {
      final desafio = await _montar(tarefaDiarioCaca(todos, nivel, hoje));
      await _comecarCaca(perfil, desafio);
    } else {
      final desafio = await _montar(tarefaDiario(todos, nivel, hoje));
      await _comecarCruzadas(perfil, desafio);
    }
  }

  Future<void> _retomar(Partida partida) async {
    final Widget tela = Modo.daPartida(partida) == Modo.caca
        ? TelaCaca(jogo: _jogoCacaDa(partida), partidaId: partida.id)
        : TelaJogo(jogo: _jogoDa(partida), partidaId: partida.id);
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => tela));
  }

  JogoCruzadas _jogoDa(Partida partida) {
    final desafio = DesafioCruzadas.deJson(
      jsonDecode(partida.desafio) as Map<String, dynamic>,
    );
    return JogoCruzadas.deJson(
      desafio,
      jsonDecode(partida.respostas) as Map<String, dynamic>,
    );
  }

  JogoCaca _jogoCacaDa(Partida partida) {
    final desafio = DesafioCaca.deJson(
      jsonDecode(partida.desafio) as Map<String, dynamic>,
    );
    return JogoCaca.deJson(
      desafio,
      jsonDecode(partida.respostas) as Map<String, dynamic>,
    );
  }

  /// Pendente desistido: continuar ou ver a resposta (encerra sem pontos).
  Future<void> _abrirDesistido(Partida partida) async {
    final escolha = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Continuar jogando'),
              subtitle: const Text('O tempo continua de onde parou.'),
              onTap: () => Navigator.pop(context, 'continuar'),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('Ver resposta'),
              subtitle: const Text('Encerra o desafio sem pontos.'),
              onTap: () => Navigator.pop(context, 'resposta'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (escolha == 'continuar') await _retomar(partida);
    if (escolha == 'resposta') await _verResposta(partida);
  }

  Future<void> _verResposta(Partida partida) async {
    final sim = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ver a resposta?'),
        content: const Text(
          'O desafio é encerrado sem pontos e não dá para continuar depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ver resposta'),
          ),
        ],
      ),
    );
    if (sim != true || !mounted) return;
    // Guarda o progresso de quando desistiu (para mostrar o que faltava).
    await Servicos.of(context).banco.salvarPartida(
      partida.id,
      estado: EstadoPartida.resposta,
      respostas: partida.respostas,
      tempoGastoSeg: partida.tempoGastoSeg,
      dicasUsadas: partida.dicasUsadas,
    );
    await _mostrarResposta(partida);
  }

  /// Abre a grade resolvida.
  Future<void> _mostrarResposta(Partida partida) async {
    final Widget tela;
    if (Modo.daPartida(partida) == Modo.caca) {
      tela = TelaRespostaCaca(jogo: _jogoCacaDa(partida)..revelarTudo());
    } else {
      tela = TelaResposta(jogo: _jogoDa(partida)..revelarTudo());
    }
    if (!mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    return StreamBuilder<List<Perfil>>(
      stream: banco.observarPerfis(),
      builder: (context, snapshot) {
        final perfil = snapshot.data
            ?.where((p) => p.id == widget.perfilId)
            .firstOrNull;
        if (perfil == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            // Seta de voltar padrão: volta para a lista de jogadores.
            leading: const BackButton(),
            title: Row(
              children: [
                AvatarJogador(avatar: perfil.avatar, raio: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(perfil.nome, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Placar da família',
                icon: const Icon(Icons.emoji_events_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TelaPlacar()),
                ),
              ),
              IconButton(
                tooltip: 'Como jogar',
                icon: const Icon(Icons.help_outline),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TelaComoJogar(),
                  ),
                ),
              ),
              StreamBuilder<int>(
                stream: banco.observarTotalPontos(perfil.id),
                builder: (context, s) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(child: Text('${s.data ?? 0} pontos')),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              FutureBuilder<List<Tema>>(
                future: _temas,
                builder: (context, s) {
                  if (s.hasError) {
                    return Center(
                      child: Text('Erro ao ler os temas: ${s.error}'),
                    );
                  }
                  if (!s.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _conteudo(context, perfil, s.data!);
                },
              ),
              if (_montando)
                const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Montando a grade...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _conteudo(BuildContext context, Perfil perfil, List<Tema> todos) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    final nivel = Nivel.porNome(perfil.nivelAtual);
    final visiveis = _visiveis(perfil, todos, nivel);
    final porCategoria = <String, List<Tema>>{};
    for (final t in visiveis) {
      porCategoria.putIfAbsent(t.categoria, () => []).add(t);
    }
    final categorias = porCategoria.keys.toList()
      ..sort((a, b) => _posicaoCategoria(a).compareTo(_posicaoCategoria(b)));
    final escolhidosVisiveis = visiveis
        .where((t) => _escolhidos.contains(t.id))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CartaoDiario(
          perfil: perfil,
          nivel: nivel,
          aoJogar: (modo) => _jogarDiario(perfil, todos, nivel, modo),
          aoRetomar: _retomar,
        ),
        const SizedBox(height: 16),
        Text('Jogo', style: texto.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<Modo>(
          showSelectedIcon: false,
          segments: [
            for (final m in Modo.values)
              ButtonSegment(
                value: m,
                icon: Icon(m.icone),
                label: Text(m.nome, maxLines: 1),
              ),
          ],
          selected: {_modo},
          onSelectionChanged: (s) => setState(() => _modo = s.first),
        ),
        const SizedBox(height: 16),
        Text('Nível', style: texto.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<Nivel>(
          showSelectedIcon: false,
          segments: [
            for (final n in Nivel.values)
              ButtonSegment(
                value: n,
                label: Text(n.nomeCurto, maxLines: 1),
                tooltip: n.nome,
              ),
          ],
          selected: {nivel},
          onSelectionChanged: (s) => banco.mudarNivel(perfil.id, s.first.name),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Temas', style: texto.titleMedium)),
            Text(
              escolhidosVisiveis == 0
                  ? 'Misturado (todos)'
                  : '$escolhidosVisiveis escolhido(s)',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            label: const Text('Misturado'),
            selected: escolhidosVisiveis == 0,
            onSelected: (_) => setState(_escolhidos.clear),
          ),
        ),
        for (final categoria in categorias)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(categoria),
            subtitle: Text(
              _resumoCategoria(porCategoria[categoria]!),
              style: texto.bodySmall,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in porCategoria[categoria]!)
                      FilterChip(
                        label: Text(t.nome),
                        selected: _escolhidos.contains(t.id),
                        onSelected: (sim) => setState(
                          () => sim
                              ? _escolhidos.add(t.id)
                              : _escolhidos.remove(t.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: texto.titleLarge,
          ),
          icon: Icon(_modo.icone),
          label: Text(
            _modo == Modo.caca ? 'Jogar caça-palavras' : 'Jogar cruzadas',
          ),
          onPressed: visiveis.isEmpty || _montando
              ? null
              : () => _jogar(perfil, visiveis, nivel),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.military_tech_outlined),
                label: const Text('Recordes'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TelaRecordes(perfil: perfil),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Conquistas'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TelaConquistas(perfil: perfil),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<Partida>>(
          stream: banco.observarPendentes(perfil.id),
          builder: (context, s) {
            final pendentes = s.data ?? const [];
            if (pendentes.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pendentes', style: texto.titleMedium),
                for (final p in pendentes)
                  Card(
                    child: ListTile(
                      leading: Icon(Modo.daPartida(p).icone),
                      title: Text(descreverPartida(p, todos)),
                      subtitle: Text(
                        '${p.estado == EstadoPartida.desistido ? 'Desistiu' : 'Em andamento'}'
                        ' · ${formatarTempo(p.tempoGastoSeg)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => p.estado == EstadoPartida.desistido
                          ? _abrirDesistido(p)
                          : _retomar(p),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        StreamBuilder<List<Partida>>(
          stream: banco.observarConcluidas(perfil.id),
          builder: (context, s) {
            final feitas = s.data ?? const [];
            if (feitas.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Concluídos', style: texto.titleMedium),
                for (final p in feitas.take(10))
                  if (p.estado == EstadoPartida.resposta)
                    ListTile(
                      leading: const Icon(Icons.visibility_outlined),
                      title: Text(descreverPartida(p, todos)),
                      subtitle: const Text('Viu a resposta · sem pontos'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _mostrarResposta(p),
                    )
                  else
                    ListTile(
                      leading: Icon(Modo.daPartida(p).icone),
                      title: Text(descreverPartida(p, todos)),
                      subtitle: Text(
                        '${formatarTempo(p.tempoGastoSeg)}'
                        ' · ${p.dicasUsadas} dica(s)',
                      ),
                      trailing: Text('${p.pontos} pts'),
                    ),
              ],
            );
          },
        ),
      ],
    );
  }

  int _posicaoCategoria(String c) {
    final i = ordemCategorias.indexOf(c);
    return i < 0 ? ordemCategorias.length : i;
  }

  String _resumoCategoria(List<Tema> temas) {
    final escolhidos = temas.where((t) => _escolhidos.contains(t.id)).length;
    final total = '${temas.length} tema(s)';
    return escolhidos == 0 ? total : '$total · $escolhidos escolhido(s)';
  }
}

/// Cartão do desafio do dia: um para cada modo (jogar, continuar ou ver o
/// resultado), com a sequência de dias jogados.
class _CartaoDiario extends StatelessWidget {
  const _CartaoDiario({
    required this.perfil,
    required this.nivel,
    required this.aoJogar,
    required this.aoRetomar,
  });

  final Perfil perfil;
  final Nivel nivel;
  final ValueChanged<Modo> aoJogar;
  final ValueChanged<Partida> aoRetomar;

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;

    return Card(
      color: CoresMarca.amarelo.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Desafio do dia', style: texto.titleLarge),
                ),
                StreamBuilder<Set<String>>(
                  stream: banco.observarDiasDoDiario(perfil.id),
                  builder: (context, s) {
                    final dias = DesafioDiario.diasSeguidos(
                      s.data ?? const {},
                      DateTime.now(),
                    );
                    if (dias == 0) return const SizedBox.shrink();
                    return Text(
                      '🔥 $dias ${dias == 1 ? 'dia' : 'dias seguidos'}',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Nível ${nivel.nome}. As mesmas grades para todo mundo hoje.'),
            for (final modo in Modo.values) ...[
              const SizedBox(height: 12),
              _linhaDoModo(context, banco, modo),
            ],
          ],
        ),
      ),
    );
  }

  Widget _linhaDoModo(BuildContext context, Banco banco, Modo modo) {
    final hoje = DesafioDiario.data(DateTime.now());
    final id = modo == Modo.caca
        ? DesafioCaca.idDiario(nivel, hoje)
        : DesafioCruzadas.idDiario(nivel, hoje);
    return StreamBuilder<Partida?>(
      stream: banco.observarPartidaDoDesafio(perfil.id, id),
      builder: (context, s) {
        final partida = s.data;
        if (partida?.estado == EstadoPartida.concluido) {
          return Text(
            '✅ ${modo.nome}: ${partida!.pontos} pontos em '
            '${formatarTempo(partida.tempoGastoSeg)}. Volte amanhã!',
          );
        }
        if (partida?.estado == EstadoPartida.resposta) {
          return Text('${modo.nome}: você viu a resposta. Amanhã tem outro!');
        }
        if (partida != null) {
          return FilledButton.tonalIcon(
            icon: Icon(modo.icone),
            label: Text('Continuar: ${modo.nome}'),
            onPressed: () => aoRetomar(partida),
          );
        }
        return FilledButton.icon(
          icon: Icon(modo.icone),
          label: Text('Jogar: ${modo.nome}'),
          onPressed: () => aoJogar(modo),
        );
      },
    );
  }
}

/// "Médio · Animais, Frutas", "Caça-palavras · Leve · Misturado" ou
/// "Desafio do dia · Leve".
String descreverPartida(Partida p, List<Tema> temas) {
  final partes = p.desafioId.split(':');
  final modo = Modo.daPartida(p) == Modo.caca ? 'Caça-palavras · ' : '';
  if (partes.length >= 4 && partes[1] == 'diario') {
    final nivel = Nivel.porNome(partes[2]);
    return '${modo}Desafio do dia · ${nivel.nome}';
  }
  if (partes.length < 3) return 'Cruzadas';
  final nivel = Nivel.porNome(partes[1]);
  final ids = partes[2].split('+');
  final nomes = ids.length > 3
      ? 'Misturado'
      : temas.where((t) => ids.contains(t.id)).map((t) => t.nome).join(', ');
  return '$modo${nivel.nome} · $nomes';
}

String formatarTempo(int segundos) {
  final m = segundos ~/ 60;
  final s = segundos % 60;
  return '${m}min${s.toString().padLeft(2, '0')}s';
}

// As tarefas do Isolate.run ficam fora da tela: uma closure
// criada dentro de um método da tela levaria junto a tela inteira, que
// não pode ser enviada para outro isolate.
DesafioCruzadas Function() tarefaCruzadas(
  List<Tema> temas,
  Nivel nivel,
  int semente,
) =>
    () => const GeradorCruzadas().gerar(
      temas: temas,
      nivel: nivel,
      semente: semente,
    );

DesafioCruzadas Function() tarefaDiario(
  List<Tema> todos,
  Nivel nivel,
  DateTime dia,
) =>
    () => DesafioDiario.gerar(todos, nivel, dia);

DesafioCaca Function() tarefaCaca(List<Tema> temas, Nivel nivel, int semente) =>
    () =>
        const GeradorCaca().gerar(temas: temas, nivel: nivel, semente: semente);

DesafioCaca Function() tarefaDiarioCaca(
  List<Tema> todos,
  Nivel nivel,
  DateTime dia,
) =>
    () => DesafioDiario.gerarCaca(todos, nivel, dia);
