import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/premium.dart';
import '../widgets/icones_jogo.dart';

/// Versão mostrada na tela Sobre. Mantenha igual à de `pubspec.yaml`
/// (um teste confere).
const versaoApp = '1.0.0';

/// Arquivo da política de privacidade (o mesmo texto vira a página web).
const arquivoPolitica = 'assets/textos/politica-de-privacidade.md';

/// Arquivo dos termos de uso (também vira página web).
const arquivoTermos = 'assets/textos/termos-de-uso.md';

/// Sobre o app: versão, quem faz e o resumo de privacidade, com o texto
/// completo da política.
class TelaSobre extends StatelessWidget {
  const TelaSobre({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre e privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: IconeCruzadas(tamanho: 72)),
          const SizedBox(height: 12),
          Text(
            'Palavras Cruzadas',
            textAlign: TextAlign.center,
            style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const VersaoComCodigo(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/marca/vilela.png', height: 24),
              const SizedBox(width: 8),
              Text('feito pela Vilela Digit', style: texto.titleSmall),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: CoresMarca.verdeClaro.withValues(alpha: 0.18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔒 Sua privacidade',
                    style: texto.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final item in const [
                    'Não precisa de conta, login nem e-mail.',
                    'Jogadores, fotos e pontos ficam só neste celular.',
                    'Sem anúncios e sem rastreio.',
                    'Nada dos jogadores é enviado. A internet é usada só '
                        'pela biblioteca de compras do Google Play.',
                    'Compartilhar resultado é escolha sua, e vai sem nome.',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: CoresMarca.verde,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.policy_outlined),
            label: const Text('Ler a política de privacidade completa'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TelaTextoMarkdown(
                  titulo: 'Política de privacidade',
                  arquivo: arquivoPolitica,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.description_outlined),
            label: const Text('Ler os termos de uso'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TelaTextoMarkdown(
                  titulo: 'Termos de uso',
                  arquivo: arquivoTermos,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dúvidas, sugestões ou erros nas palavras: fernando.vilela@vileladigit.com.br\nvileladigit.com.br',
            textAlign: TextAlign.center,
            style: texto.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Linha da versão. Sete toques seguidos abrem o campo do código de
/// revisor do Google Play (ver [ServicoPremium.usarCodigoRevisor]).
class VersaoComCodigo extends StatefulWidget {
  const VersaoComCodigo({super.key});

  static const toquesParaAbrir = 7;

  @override
  State<VersaoComCodigo> createState() => _VersaoComCodigoState();
}

class _VersaoComCodigoState extends State<VersaoComCodigo> {
  int _toques = 0;

  Future<void> _tocou() async {
    _toques++;
    if (_toques < VersaoComCodigo.toquesParaAbrir) return;
    _toques = 0;
    final premium = Servicos.of(context).premium;
    final mensageiro = ScaffoldMessenger.of(context);
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoCodigo(),
    );
    if (codigo == null || codigo.trim().isEmpty) return;
    final ok = await premium.usarCodigoRevisor(codigo);
    mensageiro
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Premium liberado neste celular.' : 'Código inválido.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tocou,
      child: Text(
        ServicoPremium.liberadoParaTeste
            ? 'Versão $versaoApp · 🧪 teste com Premium liberado'
            : 'Versão $versaoApp',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _DialogoCodigo extends StatefulWidget {
  const _DialogoCodigo();

  @override
  State<_DialogoCodigo> createState() => _DialogoCodigoState();
}

class _DialogoCodigoState extends State<_DialogoCodigo> {
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Código de acesso'),
      content: TextField(
        controller: _campo,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(hintText: 'Código'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_campo.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Mostra um texto em Markdown simples guardado nos assets: "# " título,
/// "## " seção, "- " item de lista, **negrito** e parágrafos.
class TelaTextoMarkdown extends StatelessWidget {
  const TelaTextoMarkdown({
    super.key,
    required this.titulo,
    required this.arquivo,
  });

  final String titulo;
  final String arquivo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(arquivo),
        builder: (context, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              for (final bloco in blocosMarkdown(s.data!))
                _bloco(context, bloco),
            ],
          );
        },
      ),
    );
  }

  Widget _bloco(BuildContext context, BlocoTexto b) {
    final texto = Theme.of(context).textTheme;
    final (estilo, topo) = switch (b.tipo) {
      TipoBloco.titulo => (
        texto.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        0.0,
      ),
      TipoBloco.secao => (
        texto.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        18.0,
      ),
      _ => (texto.bodyLarge, 6.0),
    };
    final conteudo = Text.rich(_negrito(b.texto), style: estilo);
    return Padding(
      padding: EdgeInsets.only(top: topo),
      child: b.tipo == TipoBloco.item
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: conteudo),
              ],
            )
          : conteudo,
    );
  }

  /// Transforma **assim** em negrito.
  static TextSpan _negrito(String s) {
    final partes = s.split('**');
    return TextSpan(
      children: [
        for (var i = 0; i < partes.length; i++)
          TextSpan(
            text: partes[i],
            style: i.isOdd
                ? const TextStyle(fontWeight: FontWeight.w700)
                : null,
          ),
      ],
    );
  }
}

enum TipoBloco { titulo, secao, item, paragrafo }

typedef BlocoTexto = ({TipoBloco tipo, String texto});

/// Divide o Markdown simples em blocos. Linhas seguidas de um parágrafo
/// são juntadas (com quebra de linha, como no contato).
List<BlocoTexto> blocosMarkdown(String md) {
  final blocos = <BlocoTexto>[];
  final paragrafo = <String>[];
  void fecharParagrafo() {
    if (paragrafo.isEmpty) return;
    blocos.add((tipo: TipoBloco.paragrafo, texto: paragrafo.join('\n')));
    paragrafo.clear();
  }

  for (final linha in md.split('\n').map((l) => l.trimRight())) {
    if (linha.isEmpty) {
      fecharParagrafo();
    } else if (linha.startsWith('## ')) {
      fecharParagrafo();
      blocos.add((tipo: TipoBloco.secao, texto: linha.substring(3)));
    } else if (linha.startsWith('# ')) {
      fecharParagrafo();
      blocos.add((tipo: TipoBloco.titulo, texto: linha.substring(2)));
    } else if (linha.startsWith('- ')) {
      fecharParagrafo();
      blocos.add((tipo: TipoBloco.item, texto: linha.substring(2)));
    } else {
      paragrafo.add(linha);
    }
  }
  fecharParagrafo();
  return blocos;
}
