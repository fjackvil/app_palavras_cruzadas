import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/caca_palavras.dart';
import '../dominio/desafio.dart';
import '../dominio/desafio_diario.dart';
import '../dominio/gerador_cruzadas.dart';
import '../dominio/nivel.dart';
import '../dominio/plano.dart';
import '../dominio/tema.dart';
import '../widgets/avatar.dart';
import '../widgets/escolhas_inicio.dart';
import '../widgets/icones_jogo.dart';
import 'abrir_jogo.dart';
import 'tela_como_jogar.dart';
import 'tela_conquistas.dart';
import 'tela_placar.dart';
import 'tela_premium.dart';
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

  /// O jogo escolhido na primeira tela, se veio de um cartão.
  Modo? get _escolhido => widget.modoInicial;

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
      return await montarGrade(montar);
    } finally {
      if (mounted) setState(() => _montando = false);
    }
  }

  /// Desafios livres começados hoje (para o limite do plano grátis).
  Future<int>? _hoje;

  Future<int> _contarHoje(int perfilId) =>
      _hoje ??= Servicos.of(context).banco
          .desafiosHoje(perfilId, DateTime.now());

  Future<void> _jogar(Perfil perfil, List<Tema> visiveis, Nivel nivel) async {
    if (_montando) return;
    final plano = Servicos.of(context).plano;
    _hoje = null;
    final hoje = await _contarHoje(perfil.id);
    if (!mounted) return;
    if (!plano.podeComecarDesafio(hoje)) {
      await abrirPremium(
        context,
        motivo:
            'Você já jogou os ${PlanoGratis.desafiosPorDia} desafios grátis '
            'de hoje. Amanhã tem mais, e o desafio do dia continua liberado. '
            'Com o Premium, é sem limite.',
      );
      return;
    }
    final escolhidos = visiveis
        .where((t) => _escolhidos.contains(t.id))
        .toList();
    final temas = escolhidos.isEmpty ? visiveis : escolhidos;
    final semente = Random().nextInt(1 << 31);
    if (_modo == Modo.caca) {
      final desafio = await _montar(tarefaCaca(temas, nivel, semente));
      if (mounted) await comecarCaca(context, perfil.id, desafio);
    } else {
      final desafio = await _montar(tarefaCruzadas(temas, nivel, semente));
      if (mounted) await comecarCruzadas(context, perfil.id, desafio);
    }
    // Atualiza o "hoje: x de 3" ao voltar do jogo.
    if (mounted) setState(() => _hoje = null);
  }

  Future<void> _retomarAqui(Partida partida) =>
      retomarPartida(context, partida);

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
    if (escolha == 'continuar') await _retomarAqui(partida);
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
      tela = TelaRespostaCaca(jogo: jogoCacaDa(partida)..revelarTudo());
    } else {
      tela = TelaResposta(jogo: jogoCruzadasDa(partida)..revelarTudo());
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
            backgroundColor: CoresMarca.verde,
            foregroundColor: Colors.white,
            title: Text(_escolhido?.nome ?? 'Vamos jogar!'),
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
    final plano = Servicos.of(context).plano;
    final texto = Theme.of(context).textTheme;
    // No grátis, quem estava num nível do Premium joga o Médio.
    final nivel = plano.nivelEfetivo(Nivel.porNome(perfil.nivelAtual));
    final visiveis = _visiveis(perfil, todos, nivel);
    final jogaveis = visiveis.where(plano.temaLiberado).toList();
    final porCategoria = <String, List<Tema>>{};
    for (final t in visiveis) {
      porCategoria.putIfAbsent(t.categoria, () => []).add(t);
    }
    final categorias = porCategoria.keys.toList()
      ..sort((a, b) => _posicaoCategoria(a).compareTo(_posicaoCategoria(b)));
    final escolhidosVisiveis = visiveis
        .where((t) => _escolhidos.contains(t.id))
        .length;

    final ordenado = {for (final c in categorias) c: porCategoria[c]!};
    final jogar = _modo == Modo.caca ? 'Jogar caça-palavras' : 'Jogar cruzadas';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _CabecalhoJogador(perfil: perfil),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quem chegou pelo cartão Cruzadas ou Caça-palavras já escolheu o
                    // jogo: não pergunta de novo.
                    if (_escolhido == null) ...[
                      Text('Qual jogo?', style: texto.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final m in Modo.values)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: CartaoEscolha(
                                  escolhido: _modo == m,
                                  aoTocar: () => setState(() => _modo = m),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      m == Modo.caca
                                          ? const IconeCaca(tamanho: 30)
                                          : const IconeCruzadas(tamanho: 30),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          m.nome,
                                          style: texto.labelLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text('Nível', style: texto.titleMedium),
                    const SizedBox(height: 8),
                    SeletorNivel(
                      atual: nivel,
                      aoEscolher: (n) => banco.mudarNivel(perfil.id, n.name),
                      bloqueado: (n) => !plano.nivelLiberado(n),
                      aoBloqueado: (n) => abrirPremium(
                        context,
                        motivo:
                            'O nível ${n.nome} faz parte do Premium. No '
                            'grátis dá para jogar o Leve e o Médio.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Temas', style: texto.titleMedium),
                        ),
                        Text(
                          escolhidosVisiveis == 0
                              ? 'Misturado'
                              : '$escolhidosVisiveis escolhido(s)',
                          style: texto.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GradeTemas(
                      porCategoria: ordenado,
                      escolhidos: _escolhidos,
                      aoMudar: (novos) => setState(
                        () => _escolhidos
                          ..clear()
                          ..addAll(novos),
                      ),
                      bloqueado: (t) => !plano.temaLiberado(t),
                      aoBloqueado: () => abrirPremium(
                        context,
                        motivo:
                            'Esse tema faz parte do Premium. No grátis são '
                            '10 temas; no Premium, todos os ${todos.length}.',
                      ),
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
                        final pendentes = _doJogo(s.data ?? const []);
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
                                  onTap: () =>
                                      p.estado == EstadoPartida.desistido
                                      ? _abrirDesistido(p)
                                      : _retomarAqui(p),
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
                        final feitas = _doJogo(s.data ?? const []);
                        if (feitas.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Concluídos', style: texto.titleMedium),
                            for (final p in feitas.take(10))
                              if (p.estado == EstadoPartida.resposta)
                                ListTile(
                                  leading: const Icon(
                                    Icons.visibility_outlined,
                                  ),
                                  title: Text(descreverPartida(p, todos)),
                                  subtitle: const Text(
                                    'Viu a resposta · sem pontos',
                                  ),
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
                ),
              ),
            ],
          ),
        ),
        // Botão de jogar sempre à vista, sem precisar rolar, num painel
        // branco que "flutua" sobre a lista.
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!plano.premium)
                    FutureBuilder<int>(
                      future: _contarHoje(perfil.id),
                      builder: (context, s) {
                        final resta = plano.desafiosRestantes(s.data ?? 0) ?? 0;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => abrirPremium(context),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: resta == 0
                                        ? CoresMarca.vermelho.withValues(
                                            alpha: 0.12,
                                          )
                                        : CoresMarca.verdeClaro.withValues(
                                            alpha: 0.2,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    resta == 0
                                        ? '🎟️ Acabaram os grátis de hoje'
                                        : '🎟️ $resta de '
                                              '${PlanoGratis.desafiosPorDia} '
                                              'grátis hoje',
                                    style: texto.labelLarge,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '⭐ Premium',
                                  style: texto.labelLarge?.copyWith(
                                    color: CoresMarca.verde,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  BotaoJogar(
                    titulo: jogar,
                    subtitulo:
                        'Nível ${nivel.nome} · '
                        '${escolhidosVisiveis == 0
                            ? 'temas misturados'
                            : escolhidosVisiveis == 1
                            ? '1 tema'
                            : '$escolhidosVisiveis temas'}',
                    icone: _modo == Modo.caca
                        ? const IconeCaca(tamanho: 36)
                        : const IconeCruzadas(tamanho: 36),
                    aoTocar: jogaveis.isEmpty || _montando
                        ? null
                        : () => _jogar(perfil, jogaveis, nivel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Com o jogo já escolhido, as listas mostram só as partidas dele.
  List<Partida> _doJogo(List<Partida> partidas) => _escolhido == null
      ? partidas
      : partidas.where((p) => Modo.daPartida(p) == _escolhido).toList();

  int _posicaoCategoria(String c) {
    final i = ordemCategorias.indexOf(c);
    return i < 0 ? ordemCategorias.length : i;
  }
}

/// Topo colorido da tela do jogador: avatar grande, saudação e pontos.
class _CabecalhoJogador extends StatelessWidget {
  const _CabecalhoJogador({required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [CoresMarca.verde, CoresMarca.verdeClaro],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: AvatarJogador(
              avatar: perfil.avatar,
              raio: 32,
              fundo: const Color(0xFFFFF3C4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${perfil.nome}!',
                  overflow: TextOverflow.ellipsis,
                  style: texto.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<int>(
                  stream: banco.observarTotalPontos(perfil.id),
                  builder: (context, s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⭐ ${s.data ?? 0} pontos',
                      style: texto.titleSmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
