import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dados/oferta_nivel.dart';
import '../dominio/desafio.dart';
import '../dominio/jogo_cruzadas.dart';
import '../dominio/compartilhar.dart';
import '../dominio/nivel.dart';
import '../dominio/pontuacao.dart';
import '../widgets/grade_com_zoom.dart';
import '../widgets/teclado.dart';
import 'tela_inicio.dart' show formatarTempo;
import 'tela_resultado.dart';

/// Tela de jogo das cruzadas. Salva o progresso a cada letra.
class TelaJogo extends StatefulWidget {
  const TelaJogo({super.key, required this.jogo, required this.partidaId});

  final JogoCruzadas jogo;
  final int partidaId;

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> with WidgetsBindingObserver {
  Timer? _relogio;
  bool _pausado = false;
  bool _mostrarTempo = true;
  bool _encerrado = false;

  JogoCruzadas get _jogo => widget.jogo;
  Banco get _banco => Servicos.of(context).banco;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _jogo.addListener(_aoMudar);
    _ligarRelogio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _jogo.removeListener(_aoMudar);
    _relogio?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_encerrado) {
      _pausar();
      _salvar();
    }
  }

  void _aoMudar() => setState(() {});

  void _ligarRelogio() {
    _relogio?.cancel();
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pausado || _encerrado || !_jogo.comecou) return;
      _jogo.contarSegundo();
      if (_jogo.segundos % 5 == 0) _salvar();
    });
  }

  void _pausar() => setState(() => _pausado = true);

  Future<void> _salvar({
    String estado = EstadoPartida.andamento,
    int pontos = 0,
  }) => _banco.salvarPartida(
    widget.partidaId,
    estado: estado,
    respostas: jsonEncode(_jogo.paraJson()),
    tempoGastoSeg: _jogo.segundos,
    dicasUsadas: _jogo.dicasUsadas,
    pontos: pontos,
  );

  /// Executa uma ação do jogador, salva e confere se acabou.
  Future<void> _acao(VoidCallback acao) async {
    if (_pausado || _encerrado) return;
    acao();
    if (_jogo.concluido) {
      await _concluir();
    } else {
      await _salvar();
    }
  }

  Future<void> _concluir() async {
    _encerrado = true;
    _relogio?.cancel();
    final pontuacao = _jogo.pontuacao;
    await _salvar(estado: EstadoPartida.concluido, pontos: pontuacao.total);
    final (perfilId, proximo) = await ofertaDeNivel(_banco, widget.partidaId);
    final recordes = await recordesBatidos(_banco, widget.partidaId);
    final medalhas = await conquistasLiberadas(_banco, widget.partidaId);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TelaResultado(
          nivel: _jogo.nivel,
          palavras: [
            for (final p in _jogo.desafio.palavras)
              (
                rotulo: '${p.numero} ${p.horizontal ? '→' : '↓'}',
                escrita: p.escrita,
                dica: p.dica,
              ),
          ],
          pontuacao: pontuacao,
          textoCompartilhar: textoResultado(
            caca: false,
            nivel: _jogo.nivel,
            diario: _jogo.desafio.diario,
            pontos: pontuacao.total,
            segundos: _jogo.segundos,
            dicas: _jogo.dicasUsadas,
            palavras: _jogo.desafio.palavras.length,
          ),
          segundos: _jogo.segundos,
          perfilId: perfilId,
          proximoNivel: proximo,
          recordes: recordes,
          conquistas: medalhas,
        ),
      ),
    );
  }

  /// Confere se a pessoa fez 3 desafios seguidos rápido e sem dicas.
  Future<void> _desistir() async {
    final sim = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desistir deste desafio?'),
        content: const Text(
          'Nada é apagado: ele fica em Pendentes e você pode voltar depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar jogando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desistir'),
          ),
        ],
      ),
    );
    if (sim != true) return;
    _encerrado = true;
    _relogio?.cancel();
    await _salvar(estado: EstadoPartida.desistido);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _escolherDica() async {
    final escolha = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Revelar uma letra'),
              trailing: Text('-${Pontuacao.custoDicaLetra} pts'),
              onTap: () => Navigator.pop(context, 'letra'),
            ),
            ListTile(
              leading: const Icon(Icons.short_text),
              title: const Text('Revelar a palavra'),
              trailing: Text('-${Pontuacao.custoDicaPalavra} pts'),
              onTap: () => Navigator.pop(context, 'palavra'),
            ),
          ],
        ),
      ),
    );
    if (escolha == 'letra') await _acao(_jogo.dicaDeLetra);
    if (escolha == 'palavra') await _acao(_jogo.dicaDePalavra);
  }

  void _verificar() {
    if (_pausado || _encerrado) return;
    final certa = _jogo.verificarPalavra();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            certa
                ? 'Palavra certa!'
                : 'Ainda não. As letras erradas ficaram vermelhas.',
          ),
        ),
      );
  }

  Future<void> _verTodasAsDicas() async {
    final escolhida = await showModalBottomSheet<PalavraNaGrade>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, rolagem) => ListView(
          controller: rolagem,
          children: [
            for (final horizontal in const [true, false]) ...[
              ListTile(
                title: Text(
                  horizontal ? 'Horizontais' : 'Verticais',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final p in _jogo.desafio.palavras.where(
                (p) => p.horizontal == horizontal,
              ))
                ListTile(
                  leading: Text('${p.numero}'),
                  title: Text(p.dica),
                  subtitle: Text('${p.tamanho} letras'),
                  trailing: _jogo.palavraCompleta(p)
                      ? const Icon(Icons.check, color: CoresMarca.verde)
                      : null,
                  onTap: () => Navigator.pop(context, p),
                ),
            ],
          ],
        ),
      ),
    );
    if (escolhida != null) _jogo.selecionarPalavra(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final leve = _jogo.nivel == Nivel.leve;
    final atual = _jogo.palavraAtual;
    final texto = Theme.of(context).textTheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_encerrado) _salvar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            !_jogo.comecou
                ? 'Toque para começar'
                : _mostrarTempo
                ? formatarTempo(_jogo.segundos)
                : _jogo.nivel.nome,
          ),
          actions: [
            if (leve)
              IconButton(
                tooltip: _mostrarTempo ? 'Esconder o tempo' : 'Mostrar o tempo',
                icon: Icon(
                  _mostrarTempo ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _mostrarTempo = !_mostrarTempo),
              ),
            IconButton(
              tooltip: _pausado ? 'Continuar' : 'Pausar',
              icon: Icon(_pausado ? Icons.play_arrow : Icons.pause),
              onPressed: () => setState(() => _pausado = !_pausado),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _pausado
                      ? Center(
                          child: _Pausado(
                            aoContinuar: () => setState(() => _pausado = false),
                          ),
                        )
                      : GradeComZoom(jogo: _jogo),
                ),
              ),
              Material(
                color: CoresMarca.verdeClaro.withValues(alpha: 0.2),
                child: InkWell(
                  onTap: _verTodasAsDicas,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            atual == null
                                ? 'Toque numa casa'
                                : '${atual.numero} ${atual.horizontal ? '→' : '↓'}  ${atual.dica}',
                            style: leve ? texto.titleLarge : texto.titleMedium,
                          ),
                        ),
                        const Icon(Icons.list),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('Dica'),
                      onPressed: _encerrado ? null : _escolherDica,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.spellcheck),
                      label: const Text('Verificar'),
                      onPressed: _encerrado ? null : _verificar,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Desistir'),
                      onPressed: _encerrado ? null : _desistir,
                    ),
                  ],
                ),
              ),
              Teclado(
                grande: leve,
                aoDigitar: (l) => _acao(() => _jogo.digitar(l)),
                aoApagar: () => _acao(_jogo.apagar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pausado extends StatelessWidget {
  const _Pausado({required this.aoContinuar});

  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Pausado', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Continuar'),
          onPressed: aoContinuar,
        ),
      ],
    );
  }
}
