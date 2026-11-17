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
    this.bloqueado,
    this.aoBloqueado,
  });

  final Nivel atual;
  final ValueChanged<Nivel> aoEscolher;

  /// Níveis do Premium, quando o aparelho está no grátis.
  final bool Function(Nivel)? bloqueado;
  final ValueChanged<Nivel>? aoBloqueado;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final n in Nivel.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Builder(
                builder: (context) {
                  final travado = bloqueado?.call(n) ?? false;
                  return CartaoEscolha(
                    escolhido: n == atual,
                    aoTocar: () =>
                        travado ? aoBloqueado?.call(n) : aoEscolher(n),
                    child: Column(
                      children: [
                        Text(
                          travado ? '🔒' : emojiNivel[n]!,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          n.nomeCurto,
                          style: texto.labelLarge?.copyWith(
                            fontWeight: n == atual ? FontWeight.w800 : null,
                            color: travado ? Colors.grey.shade600 : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
    this.bloqueado,
    this.aoBloqueado,
  });

  /// Temas do Premium, quando o aparelho está no grátis.
  final bool Function(Tema)? bloqueado;
  final VoidCallback? aoBloqueado;

  bool _travado(Tema t) => bloqueado?.call(t) ?? false;

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
                      // Marca ou desmarca todos os temas da categoria.
                      Builder(
                        builder: (context) {
                          // Só os temas liberados entram no "todos".
                          final livres = temas
                              .where((t) => !_travado(t))
                              .toList();
                          final todos =
                              livres.isNotEmpty &&
                              livres.every((t) => marcados.contains(t.id));
                          final alguns =
                              !todos &&
                              livres.any((t) => marcados.contains(t.id));
                          return CheckboxListTile(
                            tristate: true,
                            value: todos ? true : (alguns ? null : false),
                            title: Text(
                              todos ? 'Desmarcar todos' : 'Marcar todos',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onChanged: (_) => setSheet(() {
                              if (todos) {
                                marcados.removeAll(livres.map((t) => t.id));
                              } else {
                                marcados.addAll(livres.map((t) => t.id));
                              }
                            }),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      for (final t in temas.where((t) => !_travado(t)))
                        CheckboxListTile(
                          value: marcados.contains(t.id),
                          title: Text(t.nome),
                          onChanged: (sim) => setSheet(
                            () => sim == true
                                ? marcados.add(t.id)
                                : marcados.remove(t.id),
                          ),
                        ),
                      if (temas.any(_travado))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            temas.every(_travado)
                                ? '🔒 Todos os temas desta categoria são do '
                                      'Premium'
                                : '🔒 Estes são do Premium',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      for (final t in temas.where(_travado))
                        ListTile(
                          leading: const Text('🔒'),
                          title: Text(t.nome),
                          subtitle: const Text('Premium'),
                          onTap: () {
                            Navigator.pop(context);
                            aoBloqueado?.call();
                          },
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
                resumoCategoria(
                  total: temas.length,
                  escolhidos: n,
                  travados: temas.where(_travado).length,
                ),
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

/// Texto curto embaixo do nome da categoria: quantos temas, quantos
/// escolhidos e quantos são do Premium.
String resumoCategoria({
  required int total,
  required int escolhidos,
  required int travados,
}) {
  if (escolhidos > 0) return '$escolhidos de $total ✓';
  if (travados == total) return '🔒 Premium';
  if (travados > 0) {
    final livres = total - travados;
    return '$livres grátis · $travados 🔒';
  }
  return '$total temas';
}

/// Botão grande de jogar, no rodapé da tela do jogo: degradê verde, o
/// desenho do jogo, o resumo do que vai ser jogado e uma seta. Encolhe um
/// pouco ao ser tocado.
class BotaoJogar extends StatefulWidget {
  const BotaoJogar({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.aoTocar,
  });

  final String titulo;
  final String subtitulo;
  final Widget icone;

  /// null = desativado (por exemplo, montando a grade).
  final VoidCallback? aoTocar;

  @override
  State<BotaoJogar> createState() => _BotaoJogarState();
}

class _BotaoJogarState extends State<BotaoJogar> {
  bool _apertado = false;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final ativo = widget.aoTocar != null;
    return Semantics(
      button: true,
      enabled: ativo,
      label: '${widget.titulo}. ${widget.subtitulo}',
      child: GestureDetector(
        onTapDown: ativo ? (_) => setState(() => _apertado = true) : null,
        onTapCancel: () => setState(() => _apertado = false),
        onTapUp: (_) => setState(() => _apertado = false),
        onTap: widget.aoTocar,
        child: AnimatedScale(
          scale: _apertado ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedOpacity(
            opacity: ativo ? 1 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [CoresMarca.verde, CoresMarca.verdeClaro],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: CoresMarca.verde.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: widget.icone,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.titulo,
                          style: texto.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          widget.subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texto.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
