import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/caca_palavras.dart';
import '../dominio/desafio.dart';
import '../dominio/desafio_diario.dart';
import '../dominio/nivel.dart';
import '../dominio/tema.dart';
import '../widgets/avatar.dart';
import '../widgets/icones_jogo.dart';
import 'abrir_jogo.dart';
import 'fim_de_jogo.dart';
import 'tela_inicio.dart'
    show Modo, formatarTempo, tarefaDiario, tarefaDiarioCaca;

const _diasDaSemana = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];
const _meses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', //
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

/// "Terça-feira, 17 de novembro"
String dataPorExtenso(DateTime d) =>
    '${_diasDaSemana[d.weekday - 1]}, ${d.day} de ${_meses[d.month - 1]}';

/// Desafio do dia de um jogador: as cruzadas e o caça-palavras do dia, com
/// a sequência de dias jogados.
class TelaDesafioDia extends StatefulWidget {
  const TelaDesafioDia({super.key, required this.perfilId});

  final int perfilId;

  @override
  State<TelaDesafioDia> createState() => _TelaDesafioDiaState();
}

class _TelaDesafioDiaState extends State<TelaDesafioDia> {
  Future<List<Tema>>? _temas;
  bool _montando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _temas ??= Servicos.of(context).temas.carregar();
  }

  Future<void> _jogar(Modo modo, List<Tema> todos, Nivel nivel) async {
    if (_montando) return;
    setState(() => _montando = true);
    final hoje = DateTime.now();
    AcaoFim? acao;
    try {
      if (modo == Modo.caca) {
        final d = await montarGrade(tarefaDiarioCaca(todos, nivel, hoje));
        if (mounted) setState(() => _montando = false);
        if (mounted) acao = await comecarCaca(context, widget.perfilId, d);
      } else {
        final d = await montarGrade(tarefaDiario(todos, nivel, hoje));
        if (mounted) setState(() => _montando = false);
        if (mounted) {
          acao = await comecarCruzadas(context, widget.perfilId, d);
        }
      }
    } finally {
      if (mounted && _montando) setState(() => _montando = false);
    }
    if (acao == AcaoFim.inicio && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicos = Servicos.of(context);
    final texto = Theme.of(context).textTheme;
    return StreamBuilder<List<Perfil>>(
      stream: servicos.banco.observarPerfis(),
      builder: (context, s) {
        final perfil = s.data
            ?.where((p) => p.id == widget.perfilId)
            .firstOrNull;
        if (perfil == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final nivel = servicos.plano.nivelEfetivo(
          Nivel.porNome(perfil.nivelAtual),
        );
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFB74D),
            foregroundColor: const Color(0xFF1B2A1B),
            title: const Text('Desafio do dia'),
          ),
          body: Stack(
            children: [
              FutureBuilder<List<Tema>>(
                future: _temas,
                builder: (context, t) {
                  if (!t.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _Cabecalho(perfil: perfil, nivel: nivel),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final modo in Modo.values) ...[
                              _CartaoModo(
                                perfil: perfil,
                                nivel: nivel,
                                modo: modo,
                                aoJogar: () => _jogar(modo, t.data!, nivel),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              'Todo dia tem um desafio novo. Quem joga no '
                              'mesmo nível recebe a mesma grade: dá para '
                              'comparar com a família!',
                              textAlign: TextAlign.center,
                              style: texto.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
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
}

/// Topo laranja: data, jogador, nível e sequência de dias.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.perfil, required this.nivel});

  final Perfil perfil;
  final Nivel nivel;

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB74D), Color(0xFFFFE08A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataPorExtenso(DateTime.now()),
                  style: texto.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AvatarJogador(avatar: perfil.avatar, raio: 12),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${perfil.nome} · nível ${nivel.nome}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                StreamBuilder<Set<String>>(
                  stream: banco.observarDiasDoDiario(perfil.id),
                  builder: (context, s) {
                    final dias = DesafioDiario.diasSeguidos(
                      s.data ?? const {},
                      DateTime.now(),
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dias == 0
                            ? '🔥 Comece sua sequência hoje!'
                            : '🔥 $dias ${dias == 1 ? 'dia' : 'dias seguidos'}',
                        style: texto.titleSmall,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de um jogo do dia: jogar, continuar ou o resultado de hoje.
class _CartaoModo extends StatelessWidget {
  const _CartaoModo({
    required this.perfil,
    required this.nivel,
    required this.modo,
    required this.aoJogar,
  });

  final Perfil perfil;
  final Nivel nivel;
  final Modo modo;
  final VoidCallback aoJogar;

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    final hoje = DesafioDiario.data(DateTime.now());
    final id = modo == Modo.caca
        ? DesafioCaca.idDiario(nivel, hoje)
        : DesafioCruzadas.idDiario(nivel, hoje);
    return StreamBuilder<Partida?>(
      stream: banco.observarPartidaDoDesafio(perfil.id, id),
      builder: (context, s) {
        final partida = s.data;
        final feito = partida?.estado == EstadoPartida.concluido;
        final viu = partida?.estado == EstadoPartida.resposta;
        final (String situacao, Widget? botao) = switch (partida) {
          _ when feito => (
            '✅ Feito: ${partida!.pontos} pontos em '
                '${formatarTempo(partida.tempoGastoSeg)}',
            null,
          ),
          _ when viu => ('Você viu a resposta. Amanhã tem outro!', null),
          final p? => (
            'Em andamento',
            FilledButton.tonal(
              onPressed: () async {
                final acao = await retomarPartida(context, p);
                if (acao == AcaoFim.inicio && context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              child: const Text('Continuar'),
            ),
          ),
          null => (
            'Ainda não jogado hoje',
            FilledButton(onPressed: aoJogar, child: const Text('Jogar')),
          ),
        };
        return Card(
          color: feito ? CoresMarca.verdeClaro.withValues(alpha: 0.2) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                modo == Modo.caca
                    ? const IconeCaca(tamanho: 48)
                    : const IconeCruzadas(tamanho: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modo == Modo.caca
                            ? 'Caça-palavras do dia'
                            : 'Cruzadas do dia',
                        style: texto.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(situacao, style: texto.bodyMedium),
                    ],
                  ),
                ),
                ?botao,
              ],
            ),
          ),
        );
      },
    );
  }
}
