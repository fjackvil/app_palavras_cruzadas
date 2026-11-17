import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/nivel.dart';
import '../dominio/tema.dart';

/// Emoji de cada categoria de temas, para a grade.
const emojiCategoria = {
  'Mundo': '🌎',
  'Natureza': '🌿',
  'Comida': '🍕',
  'Cinema e TV': '🎬',
  'Música': '🎵',
  'História': '🏛️',
  'Ciência': '🔬',
  'Esportes': '⚽',
  'Cultura': '🎭',
  'Dia a dia': '🏠',
  'Língua portuguesa': '📚',
  'Atualidades': '📰',
};

/// Emoji de cada nível.
const emojiNivel = {
  Nivel.leve: '🙂',
  Nivel.medio: '😎',
  Nivel.dificil: '🤓',
  Nivel.superDificil: '🦸',
};

/// Um cartão que "afunda" um pouco ao ser tocado e fica colorido quando
/// escolhido. Usado nos níveis, nos jogos e nos temas.
class CartaoEscolha extends StatefulWidget {
  const CartaoEscolha({
    super.key,
    required this.escolhido,
    required this.aoTocar,
    required this.child,
    this.cor = CoresMarca.verde,
  });

  final bool escolhido;
  final VoidCallback aoTocar;
  final Widget child;
  final Color cor;

  @override
  State<CartaoEscolha> createState() => _CartaoEscolhaState();
}

class _CartaoEscolhaState extends State<CartaoEscolha> {
  bool _apertado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _apertado = true),
      onTapCancel: () => setState(() => _apertado = false),
      onTapUp: (_) => setState(() => _apertado = false),
      onTap: widget.aoTocar,
      child: AnimatedScale(
        scale: _apertado ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: widget.escolhido
                ? widget.cor.withValues(alpha: 0.18)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.escolhido ? widget.cor : Colors.grey.shade300,
              width: widget.escolhido ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Os 4 níveis em cartões com emoji.
class SeletorNivel extends StatelessWidget {
  const SeletorNivel({
    super.key,
    required this.atual,
    required this.aoEscolher,
  });

  final Nivel atual;
  final ValueChanged<Nivel> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final n in Nivel.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: CartaoEscolha(
                escolhido: n == atual,
                aoTocar: () => aoEscolher(n),
                child: Column(
                  children: [
                    Text(emojiNivel[n]!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 2),
                    Text(
                      n.nomeCurto,
                      style: texto.labelLarge?.copyWith(
                        fontWeight: n == atual ? FontWeight.w800 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Temas em grade: "Misturado" e uma casa por categoria. Tocar numa
/// categoria abre a lista dos temas dela para marcar.
class GradeTemas extends StatelessWidget {
  const GradeTemas({
    super.key,
    required this.porCategoria,
    required this.escolhidos,
    required this.aoMudar,
  });

  /// Categorias na ordem da tela, com os temas visíveis de cada uma.
  final Map<String, List<Tema>> porCategoria;
  final Set<String> escolhidos;

  /// Novo conjunto de temas escolhidos (vazio = Misturado).
  final ValueChanged<Set<String>> aoMudar;

  Future<void> _abrirCategoria(
    BuildContext context,
    String categoria,
    List<Tema> temas,
  ) async {
    final marcados = {...escolhidos};
    final resultado = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${emojiCategoria[categoria] ?? '📌'} $categoria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Marque um ou mais temas.'),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final t in temas)
                        CheckboxListTile(
                          value: marcados.contains(t.id),
                          title: Text(t.nome),
                          onChanged: (sim) => setSheet(
                            () => sim == true
                                ? marcados.add(t.id)
                                : marcados.remove(t.id),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Navigator.pop(context, marcados),
                    child: const Text('Pronto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (resultado != null) aoMudar(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final itens = <Widget>[
      CartaoEscolha(
        escolhido: escolhidos.isEmpty,
        cor: CoresMarca.amarelo,
        aoTocar: () => aoMudar({}),
        child: _conteudo(texto, '🎲', 'Misturado', 'de tudo um pouco'),
      ),
      for (final MapEntry(key: categoria, value: temas) in porCategoria.entries)
        Builder(
          builder: (context) {
            final n = temas.where((t) => escolhidos.contains(t.id)).length;
            return CartaoEscolha(
              escolhido: n > 0,
              aoTocar: () => _abrirCategoria(context, categoria, temas),
              child: _conteudo(
                texto,
                emojiCategoria[categoria] ?? '📌',
                categoria,
                n > 0 ? '$n de ${temas.length} ✓' : '${temas.length} temas',
              ),
            );
          },
        ),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.05,
      children: itens,
    );
  }

  Widget _conteudo(TextTheme texto, String emoji, String nome, String info) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 2),
          Text(
            nome,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: texto.labelLarge?.copyWith(height: 1.1),
          ),
          Text(info, style: texto.bodySmall, maxLines: 1),
        ],
      );
}
