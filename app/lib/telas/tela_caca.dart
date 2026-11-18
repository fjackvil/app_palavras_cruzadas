import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dados/limite_dicas.dart';
import '../dados/oferta_nivel.dart';
import '../dominio/jogo_caca.dart';
import '../dominio/compartilhar.dart';
import '../dominio/pontuacao.dart';
import '../widgets/grade_caca.dart';
import 'tela_inicio.dart' show formatarTempo;
import 'fim_de_jogo.dart';

/// Tela de jogo do caça-palavras. Salva o progresso a cada palavra achada.
class TelaCaca extends StatefulWidget {
  const TelaCaca({super.key, required this.jogo, required this.partidaId});

  final JogoCaca jogo;
  final int partidaId;

  @override
  State<TelaCaca> createState() => _TelaCacaState();
}

class _TelaCacaState extends State<TelaCaca> with WidgetsBindingObserver {
  Timer? _relogio;
  bool _pausado = false;
  bool _mostrarTempo = true;
  bool _encerrado = false;

  /// Resultado do desafio terminado (null enquanto joga).
  ResultadoFim? _fim;

  JogoCaca get _jogo => widget.jogo;
  Banco get _banco => Servicos.of(context).banco;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _jogo.addListener(_aoMudar);
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pausado || _encerrado || !_jogo.comecou) return;
      _jogo.contarSegundo();
      if (_jogo.segundos % 5 == 0) _salvar();
    });
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
      setState(() => _pausado = true);
      _salvar();
    }
  }

  void _aoMudar() => setState(() {});

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

  Future<void> _aoAchar(int indice) async {
    final p = _jogo.desafio.palavras[indice];
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Achou: ${p.escrita}!'),
        ),
      );
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
    // Fica na tela, com a grade resolvida e o painel do fim por baixo.
    setState(
      () => _fim = ResultadoFim(
        nivel: _jogo.nivel,
        pontuacao: pontuacao,
        segundos: _jogo.segundos,
        palavras: [
          for (final p in _jogo.desafio.palavras)
            (rotulo: '•', escrita: p.escrita, dica: p.dica),
        ],
        textoCompartilhar: textoResultado(
          caca: true,
          nivel: _jogo.nivel,
          diario: _jogo.desafio.diario,
          pontos: pontuacao.total,
          segundos: _jogo.segundos,
          dicas: _jogo.dicasUsadas,
          palavras: _jogo.desafio.palavras.length,
        ),
        diario: _jogo.desafio.diario != null,
        perfilId: perfilId,
        proximoNivel: proximo,
        recordes: recordes,
        conquistas: medalhas,
      ),
    );
  }

  Future<void> _dica() async {
    if (_pausado || _encerrado) return;
    if (!await conferirDica(context) || !mounted) return;
    final sim = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usar uma dica?'),
        content: Text(
          'A primeira letra de uma palavra fica marcada com um círculo '
          'vermelho. Custa ${Pontuacao.custoDicaLetra} pontos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usar dica'),
          ),
        ],
      ),
    );
    if (sim != true || !mounted) return;
    final dada = _jogo.dica();
    if (dada != null && mounted) await contarDica(context);
    if (dada == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as palavras que faltam já têm dica.'),
        ),
      );
    }
    await _salvar();
  }

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

  @override
  Widget build(BuildContext context) {
    final leve = _jogo.nivel.facil;
    final d = _jogo.desafio;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_encerrado) _salvar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _fim != null
                ? 'Concluído! 🎉'
                : !_jogo.comecou
                ? 'Toque para começar'
                : _mostrarTempo
                ? formatarTempo(_jogo.segundos)
                : _jogo.nivel.nome,
          ),
          actions: [
            if (leve && _fim == null)
              IconButton(
                tooltip: _mostrarTempo ? 'Esconder o tempo' : 'Mostrar o tempo',
                icon: Icon(
                  _mostrarTempo ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _mostrarTempo = !_mostrarTempo),
              ),
            if (_fim == null)
              IconButton(
                tooltip: _pausado ? 'Continuar' : 'Pausar',
                icon: Icon(_pausado ? Icons.play_arrow : Icons.pause),
                onPressed: () => setState(() => _pausado = !_pausado),
              ),
          ],
        ),
        body: _fim != null
            ? Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: GradeCaca(jogo: _jogo, somenteLeitura: true),
                      ),
                    ),
                  ),
                  PainelFim(
                    resultado: _fim!,
                    aoEscolher: (acao) => Navigator.of(context).pop(acao),
                  ),
                ],
              )
            : SafeArea(
                child: _pausado
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pausado',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Continuar'),
                              onPressed: () => setState(() => _pausado = false),
                            ),
                          ],
                        ),
                      )
                    // Sem rolagem em volta da grade: o arrasto do dedo é só dela.
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${_jogo.encontradas.length} de ${d.palavras.length} '
                              'palavras · arraste o dedo sobre a palavra',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Center(
                                child: GradeCaca(
                                  jogo: _jogo,
                                  aoAchar: _aoAchar,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.lightbulb_outline),
                                label: const Text('Dica'),
                                onPressed: _encerrado ? null : _dica,
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.flag_outlined),
                                label: const Text('Desistir'),
                                onPressed: _encerrado ? null : _desistir,
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: ListaCaca(jogo: _jogo),
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}
