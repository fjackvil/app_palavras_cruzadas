import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/desafio.dart';
import '../dominio/pontuacao.dart';
import 'tela_inicio.dart' show formatarTempo;

/// Fim do desafio: pontos, tempo e as palavras com a grafia certa.
class TelaResultado extends StatelessWidget {
  const TelaResultado({
    super.key,
    required this.desafio,
    required this.pontuacao,
    required this.segundos,
  });

  final DesafioCruzadas desafio;
  final Pontuacao pontuacao;
  final int segundos;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _linha('Letras (${desafio.nivel.nome})', pontuacao.base),
                  _linha('Bônus de tempo', pontuacao.bonusTempo),
                  _linha('Bônus sem dicas', pontuacao.bonusSemDica),
                  _linha('Dicas usadas', -pontuacao.custoDicas),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Palavras', style: texto.titleMedium),
          for (final p in desafio.palavras)
            ListTile(
              dense: true,
              leading: Text('${p.numero} ${p.horizontal ? '→' : '↓'}'),
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
