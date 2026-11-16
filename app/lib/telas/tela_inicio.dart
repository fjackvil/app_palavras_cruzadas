import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/desafio.dart';
import '../dominio/desafio_diario.dart';
import '../dominio/gerador_cruzadas.dart';
import '../dominio/jogo_cruzadas.dart';
import '../dominio/nivel.dart';
import '../dominio/tema.dart';
import 'tela_jogo.dart';

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
  const TelaInicio({super.key, required this.perfilId});

  final int perfilId;

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  /// Ids dos temas escolhidos. Vazio = "Misturado".
  final Set<String> _escolhidos = {};
  Future<List<Tema>>? _temas;
  bool _montando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _temas ??= Servicos.of(context).temas.carregar();
  }

  /// Temas que o perfil pode ver no nível: os infantis para crianças e só
  /// os que têm palavras suficientes para o nível.
  List<Tema> _visiveis(Perfil perfil, List<Tema> todos, Nivel nivel) {
    final idade = DateTime.now().year - perfil.anoNascimento;
    return todos
        .where((t) => idade >= idadeTemasAdultos || t.infantil)
        .where((t) => t.disponivelPara(nivel))
        .toList();
  }

  /// Monta a grade fora da tela principal para o app não travar.
  Future<DesafioCruzadas> _montar(DesafioCruzadas Function() montar) async {
    setState(() => _montando = true);
    try {
      return await Isolate.run(montar);
    } finally {
      if (mounted) setState(() => _montando = false);
    }
  }

  Future<void> _comecar(Perfil perfil, DesafioCruzadas desafio) async {
    final jogo = JogoCruzadas(desafio);
    final banco = Servicos.of(context).banco;
    final partidaId = await banco.iniciarPartida(
      perfilId: perfil.id,
      modo: 'cruzadas',
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

  Future<void> _jogar(Perfil perfil, List<Tema> visiveis, Nivel nivel) async {
    if (_montando) return;
    final escolhidos = visiveis
        .where((t) => _escolhidos.contains(t.id))
        .toList();
    final temas = escolhidos.isEmpty ? visiveis : escolhidos;
    final semente = Random().nextInt(1 << 31);
    final desafio = await _montar(
      () => const GeradorCruzadas().gerar(
        temas: temas,
        nivel: nivel,
        semente: semente,
      ),
    );
    await _comecar(perfil, desafio);
  }

  Future<void> _jogarDiario(
    Perfil perfil,
    List<Tema> todos,
    Nivel nivel,
  ) async {
    if (_montando) return;
    final hoje = DateTime.now();
    final desafio = await _montar(
      () => DesafioDiario.gerar(todos, nivel, hoje),
    );
    await _comecar(perfil, desafio);
  }

  Future<void> _retomar(Partida partida) async {
    final desafio = DesafioCruzadas.deJson(
      jsonDecode(partida.desafio) as Map<String, dynamic>,
    );
    final jogo = JogoCruzadas.deJson(
      desafio,
      jsonDecode(partida.respostas) as Map<String, dynamic>,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaJogo(jogo: jogo, partidaId: partida.id),
      ),
    );
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
                Text(perfil.avatar, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(perfil.nome, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            actions: [
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
          aoJogar: () => _jogarDiario(perfil, todos, nivel),
          aoRetomar: _retomar,
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
          icon: const Icon(Icons.grid_on),
          label: const Text('Jogar cruzadas'),
          onPressed: visiveis.isEmpty || _montando
              ? null
              : () => _jogar(perfil, visiveis, nivel),
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
                      leading: const Icon(Icons.pause_circle_outline),
                      title: Text(descreverPartida(p, todos)),
                      subtitle: Text(
                        '${p.estado == EstadoPartida.desistido ? 'Desistiu' : 'Em andamento'}'
                        ' · ${formatarTempo(p.tempoGastoSeg)}',
                      ),
                      trailing: const Text('Continuar'),
                      onTap: () => _retomar(p),
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
                  ListTile(
                    leading: const Icon(Icons.emoji_events_outlined),
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

/// Cartão do desafio do dia: jogar, continuar ou ver o resultado, com a
/// sequência de dias jogados.
class _CartaoDiario extends StatelessWidget {
  const _CartaoDiario({
    required this.perfil,
    required this.nivel,
    required this.aoJogar,
    required this.aoRetomar,
  });

  final Perfil perfil;
  final Nivel nivel;
  final VoidCallback aoJogar;
  final ValueChanged<Partida> aoRetomar;

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    final hoje = DesafioDiario.data(DateTime.now());
    final id = DesafioCruzadas.idDiario(nivel, hoje);

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
            Text('Nível ${nivel.nome}. A mesma grade para todo mundo hoje.'),
            const SizedBox(height: 12),
            StreamBuilder<Partida?>(
              stream: banco.observarPartidaDoDesafio(perfil.id, id),
              builder: (context, s) {
                final partida = s.data;
                if (partida?.estado == EstadoPartida.concluido) {
                  return Text(
                    '✅ Feito hoje: ${partida!.pontos} pontos em '
                    '${formatarTempo(partida.tempoGastoSeg)}. Volte amanhã!',
                  );
                }
                if (partida != null) {
                  return FilledButton.tonalIcon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Continuar o desafio do dia'),
                    onPressed: () => aoRetomar(partida),
                  );
                }
                return FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Jogar o desafio do dia'),
                  onPressed: aoJogar,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// "Médio · Animais, Frutas" ou "Desafio do dia · Leve".
String descreverPartida(Partida p, List<Tema> temas) {
  final partes = p.desafioId.split(':');
  if (partes.length >= 4 && partes[1] == 'diario') {
    final nivel = Nivel.porNome(partes[2]);
    return 'Desafio do dia · ${nivel.nome}';
  }
  if (partes.length < 3) return 'Cruzadas';
  final nivel = Nivel.porNome(partes[1]);
  final ids = partes[2].split('+');
  final nomes = ids.length > 3
      ? 'Misturado'
      : temas.where((t) => ids.contains(t.id)).map((t) => t.nome).join(', ');
  return '${nivel.nome} · $nomes';
}

String formatarTempo(int segundos) {
  final m = segundos ~/ 60;
  final s = segundos % 60;
  return '${m}min${s.toString().padLeft(2, '0')}s';
}
