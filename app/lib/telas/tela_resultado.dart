import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../dominio/compartilhar.dart';
import '../dominio/conquistas.dart';
import '../dominio/nivel.dart';
import '../dominio/pontuacao.dart';
import 'tela_inicio.dart' show formatarTempo;

/// Uma linha da lista de palavras do resultado.
typedef ItemResultado = ({String rotulo, String escrita, String dica});

/// Fim do desafio: pontos, tempo e as palavras com a grafia certa. Depois
/// de 3 desafios seguidos rápidos e sem dicas, oferece subir de nível.
class TelaResultado extends StatefulWidget {
  const TelaResultado({
    super.key,
    required this.nivel,
    required this.palavras,
    required this.pontuacao,
    required this.segundos,
    this.perfilId,
    this.proximoNivel,
    this.recordes = const [],
    this.conquistas = const [],
    this.textoCompartilhar,
  });

  final Nivel nivel;
  final List<ItemResultado> palavras;
  final Pontuacao pontuacao;
  final int segundos;
  final int? perfilId;

  /// Nível a oferecer, ou null se não há oferta.
  final Nivel? proximoNivel;

  /// Recordes batidos neste desafio ("Maior pontuação", "Melhor tempo").
  final List<String> recordes;

  /// Conquistas liberadas neste desafio.
  final List<Conquista> conquistas;

  /// Texto para o botão "Compartilhar resultado" (null = sem botão).
  final String? textoCompartilhar;

  @override
  State<TelaResultado> createState() => _TelaResultadoState();
}

class _TelaResultadoState extends State<TelaResultado> {
  /// null = ainda não respondeu; true = subiu; false = ficou.
  bool? _subiu;

  /// Abre o WhatsApp com o texto pronto. Sem o app do WhatsApp, tenta o
  /// link wa.me; se nada abrir, mostra o compartilhar do Android.
  Future<void> _whatsApp(String texto) async {
    for (final link in [linkAppWhatsApp(texto), linkWhatsApp(texto)]) {
      try {
        if (await launchUrl(link, mode: LaunchMode.externalApplication)) {
          return;
        }
      } on Object {
        // Tenta o próximo jeito.
      }
    }
    await SharePlus.instance.share(ShareParams(text: texto));
  }

  Future<void> _subir() async {
    await Servicos.of(context).banco
        .mudarNivel(widget.perfilId!, widget.proximoNivel!.name);
    if (mounted) setState(() => _subiu = true);
  }

  @override
  Widget build(BuildContext context) {
    final pontuacao = widget.pontuacao;
    final segundos = widget.segundos;
    final proximo = widget.proximoNivel;
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Desafio concluído!')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              '${pontuacao.total} pontos',
              style: texto.displaySmall?.copyWith(color: CoresMarca.verde),
            ),
          ),
          Center(child: Text('em ${formatarTempo(segundos)}')),
          if (widget.textoCompartilhar != null) ...[
            const SizedBox(height: 16),
            Text(
              'Compartilhar resultado',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            // Quem escolhe para quem mandar (ou se manda) é o jogador. O
            // texto leva o resultado e o link da loja, nada pessoal, e não
            // passa por nenhum servidor nosso.
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
                    onPressed: () => _whatsApp(widget.textoCompartilhar!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Outros apps'),
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: widget.textoCompartilhar),
                    ),
                  ),
                ),
              ],
            ),
          ],
          for (final c in widget.conquistas)
            Card(
              margin: const EdgeInsets.only(top: 16),
              color: CoresMarca.verdeClaro.withValues(alpha: 0.3),
              child: ListTile(
                leading: Text(c.emoji, style: const TextStyle(fontSize: 34)),
                title: Text('Conquista nova: ${c.nome}'),
                subtitle: Text(c.descricao),
              ),
            ),
          if (widget.recordes.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(top: 16),
              color: CoresMarca.amarelo.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Novo recorde!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${[widget.recordes.first, ...widget.recordes.skip(1).map((r) => r.toLowerCase())].join(' e ')} no nível '
                            '${widget.nivel.nome}.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (proximo != null && widget.perfilId != null && _subiu != false)
            _OfertaNivel(
              proximo: proximo,
              subiu: _subiu == true,
              aoSubir: _subir,
              aoFicar: () => setState(() => _subiu = false),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _linha('Letras (${widget.nivel.nome})', pontuacao.base),
                  _linha('Bônus de tempo', pontuacao.bonusTempo),
                  _linha('Bônus sem dicas', pontuacao.bonusSemDica),
                  _linha('Dicas usadas', -pontuacao.custoDicas),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Palavras', style: texto.titleMedium),
          for (final p in widget.palavras)
            ListTile(
              dense: true,
              leading: Text(p.rotulo),
              title: Text(p.escrita),
              subtitle: Text(p.dica),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }

  Widget _linha(String rotulo, int valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(rotulo)),
        Text(valor > 0 ? '+$valor' : '$valor'),
      ],
    ),
  );
}

class _OfertaNivel extends StatelessWidget {
  const _OfertaNivel({
    required this.proximo,
    required this.subiu,
    required this.aoSubir,
    required this.aoFicar,
  });

  final Nivel proximo;
  final bool subiu;
  final VoidCallback aoSubir;
  final VoidCallback aoFicar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: CoresMarca.verdeClaro.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: subiu
            ? Text(
                '🚀 Pronto! Agora você joga no nível ${proximo.nome}.',
                style: texto.titleMedium,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Você está mandando bem!', style: texto.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                    '3 desafios seguidos rápidos e sem dicas. '
                    'Quer tentar o próximo nível?',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: aoSubir,
                        child: Text('Subir para ${proximo.nome}'),
                      ),
                      TextButton(
                        onPressed: aoFicar,
                        child: const Text('Continuar neste nível'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
