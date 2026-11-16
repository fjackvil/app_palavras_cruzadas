import 'package:material_ui/material_ui.dart';

import '../app.dart';
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
  });

  final Nivel nivel;
  final List<ItemResultado> palavras;
  final Pontuacao pontuacao;
  final int segundos;
  final int? perfilId;

  /// Nível a oferecer, ou null se não há oferta.
  final Nivel? proximoNivel;

  @override
  State<TelaResultado> createState() => _TelaResultadoState();
}

class _TelaResultadoState extends State<TelaResultado> {
  /// null = ainda não respondeu; true = subiu; false = ficou.
  bool? _subiu;

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
