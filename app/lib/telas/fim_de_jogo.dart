import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../dados/sons.dart';
import '../dominio/compartilhar.dart';
import '../dominio/conquistas.dart';
import '../dominio/nivel.dart';
import '../dominio/pontuacao.dart';
import 'tela_inicio.dart' show formatarTempo;
import 'tela_resultado.dart';

/// O que a pessoa escolheu fazer depois de terminar um desafio. A tela do
/// jogo devolve isso para quem a abriu.
enum AcaoFim { jogarOutro, trocarTema, inicio }

/// Tudo o que o painel de fim de jogo mostra.
class ResultadoFim {
  const ResultadoFim({
    required this.nivel,
    required this.pontuacao,
    required this.segundos,
    required this.palavras,
    required this.textoCompartilhar,
    required this.diario,
    this.perfilId,
    this.proximoNivel,
    this.recordes = const [],
    this.conquistas = const [],
  });

  final Nivel nivel;
  final Pontuacao pontuacao;
  final int segundos;
  final List<ItemResultado> palavras;
  final String textoCompartilhar;

  /// Desafio do dia: não tem "jogar outro" nem "trocar tema".
  final bool diario;
  final int? perfilId;
  final Nivel? proximoNivel;
  final List<String> recordes;
  final List<Conquista> conquistas;
}

/// Abre o WhatsApp com o texto pronto. Sem o app do WhatsApp, tenta o link
/// wa.me; se nada abrir, mostra o compartilhar do Android.
Future<void> compartilharWhatsApp(String texto) async {
  for (final link in [linkAppWhatsApp(texto), linkWhatsApp(texto)]) {
    try {
      if (await launchUrl(link, mode: LaunchMode.externalApplication)) return;
    } on Object {
      // Tenta o próximo jeito.
    }
  }
  await compartilharOutros(texto);
}

Future<void> compartilharOutros(String texto) =>
    SharePlus.instance.share(ShareParams(text: texto));

/// Painel que sobe por baixo da grade resolvida: pontos, recordes,
/// conquistas e o que fazer agora.
class PainelFim extends StatefulWidget {
  const PainelFim({
    super.key,
    required this.resultado,
    required this.aoEscolher,
  });

  final ResultadoFim resultado;
  final ValueChanged<AcaoFim> aoEscolher;

  @override
  State<PainelFim> createState() => _PainelFimState();
}

class _PainelFimState extends State<PainelFim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();
  bool _subiu = false;

  ResultadoFim get _r => widget.resultado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Sons.tocar(
        Servicos.of(context).banco,
        somDoFim(
          recorde: _r.recordes.isNotEmpty,
          conquista: _r.conquistas.isNotEmpty,
        ),
      );
    });
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  Future<void> _subirNivel() async {
    await Servicos.of(context).banco
        .mudarNivel(_r.perfilId!, _r.proximoNivel!.name);
    if (mounted) setState(() => _subiu = true);
  }

  void _detalhes() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TelaResultado(
        nivel: _r.nivel,
        palavras: _r.palavras,
        pontuacao: _r.pontuacao,
        segundos: _r.segundos,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final destaques = [
      if (_r.recordes.isNotEmpty)
        '🏅 Novo recorde: ${[_r.recordes.first, ..._r.recordes.skip(1).map((e) => e.toLowerCase())].join(' e ')}',
    ];
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _entrada, curve: Curves.easeOutBack)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pontos e tempo.
                Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _r.diario
                                ? 'Desafio do dia concluído!'
                                : 'Parabéns, concluído!',
                            style: texto.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${formatarTempo(_r.segundos)} · '
                            '${_r.pontuacao.custoDicas == 0 ? 'sem dicas' : 'com dicas'}',
                            style: texto.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_r.pontuacao.total}',
                          style: texto.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: CoresMarca.verde,
                          ),
                        ),
                        Text('pontos', style: texto.bodySmall),
                      ],
                    ),
                  ],
                ),
                for (final d in destaques)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CoresMarca.amarelo.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(d, style: texto.labelLarge),
                  ),
                // Conquista nova: nome e o que ela quer dizer.
                for (final c in _r.conquistas)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CoresMarca.verdeClaro.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(c.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conquista nova: ${c.nome}',
                                style: texto.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(c.descricao, style: texto.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_r.proximoNivel != null && _r.perfilId != null)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: CoresMarca.verdeClaro.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _subiu
                                ? '🚀 Pronto! Agora você joga no '
                                      '${_r.proximoNivel!.nome}.'
                                : '🚀 Mandou bem! Quer subir para o '
                                      '${_r.proximoNivel!.nome}?',
                            style: texto.labelLarge,
                          ),
                        ),
                        if (!_subiu)
                          TextButton(
                            onPressed: _subirNivel,
                            child: const Text('Subir'),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                // O que fazer agora.
                if (!_r.diario)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: texto.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Jogar outro'),
                    onPressed: () => widget.aoEscolher(AcaoFim.jogarOutro),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (!_r.diario) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.category_outlined),
                          label: const Text('Trocar tema'),
                          onPressed: () =>
                              widget.aoEscolher(AcaoFim.trocarTema),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Início'),
                        onPressed: () => widget.aoEscolher(AcaoFim.inicio),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        onPressed: () =>
                            compartilharWhatsApp(_r.textoCompartilhar),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Outros apps'),
                        onPressed: () =>
                            compartilharOutros(_r.textoCompartilhar),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _detalhes,
                  child: const Text('Ver pontos e palavras em detalhe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
