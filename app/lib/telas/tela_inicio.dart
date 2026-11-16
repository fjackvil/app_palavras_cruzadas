import 'dart:convert';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/desafio.dart';
import '../dominio/gerador_cruzadas.dart';
import '../dominio/jogo_cruzadas.dart';
import '../dominio/nivel.dart';
import '../dominio/tema.dart';
import 'tela_jogo.dart';

/// Tela principal de um jogador: nível, temas, pendentes e histórico.
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _temas ??= Servicos.of(context).temas.carregar();
  }

  Future<void> _jogar(Perfil perfil, List<Tema> todos) async {
    final nivel = Nivel.porNome(perfil.nivelAtual);
    final temas = _escolhidos.isEmpty
        ? todos
        : todos.where((t) => _escolhidos.contains(t.id)).toList();
    final semente = Random().nextInt(1 << 31);
    final desafio = const GeradorCruzadas().gerar(
      temas: temas,
      nivel: nivel,
      semente: semente,
    );
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
            leading: IconButton(
              tooltip: 'Trocar de jogador',
              icon: Text(perfil.avatar, style: const TextStyle(fontSize: 24)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(perfil.nome),
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
          body: FutureBuilder<List<Tema>>(
            future: _temas,
            builder: (context, s) {
              if (s.hasError) {
                return Center(child: Text('Erro ao ler os temas: ${s.error}'));
              }
              if (!s.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _conteudo(context, perfil, s.data!);
            },
          ),
        );
      },
    );
  }

  Widget _conteudo(BuildContext context, Perfil perfil, List<Tema> temas) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    final nivel = Nivel.porNome(perfil.nivelAtual);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Nível', style: texto.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<Nivel>(
          segments: [
            for (final n in Nivel.values)
              ButtonSegment(value: n, label: Text(n.nome)),
          ],
          selected: {nivel},
          onSelectionChanged: (s) => banco.mudarNivel(perfil.id, s.first.name),
        ),
        const SizedBox(height: 16),
        Text('Temas', style: texto.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Misturado'),
              selected: _escolhidos.isEmpty,
              onSelected: (_) => setState(_escolhidos.clear),
            ),
            for (final t in temas)
              FilterChip(
                label: Text(t.nome),
                selected: _escolhidos.contains(t.id),
                onSelected: (sim) => setState(
                  () => sim ? _escolhidos.add(t.id) : _escolhidos.remove(t.id),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: texto.titleLarge,
          ),
          icon: const Icon(Icons.grid_on),
          label: const Text('Jogar cruzadas'),
          onPressed: () => _jogar(perfil, temas),
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
                      title: Text(_descricao(p, temas)),
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
                    title: Text(_descricao(p, temas)),
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

  /// "Médio · Animais, Frutas" a partir do id do desafio.
  String _descricao(Partida p, List<Tema> temas) {
    final partes = p.desafioId.split(':');
    if (partes.length < 3) return 'Cruzadas';
    final nivel = Nivel.porNome(partes[1]);
    final ids = partes[2].split('+');
    final nomes = ids.length == temas.length
        ? 'Misturado'
        : temas.where((t) => ids.contains(t.id)).map((t) => t.nome).join(', ');
    return '${nivel.nome} · $nomes';
  }
}

String formatarTempo(int segundos) {
  final m = segundos ~/ 60;
  final s = segundos % 60;
  return '${m}min${s.toString().padLeft(2, '0')}s';
}
