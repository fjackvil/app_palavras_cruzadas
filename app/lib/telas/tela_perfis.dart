import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import 'tela_inicio.dart';
import 'tela_novo_perfil.dart';

/// "Quem vai jogar?": lista os jogadores do aparelho.
class TelaPerfis extends StatelessWidget {
  const TelaPerfis({super.key});

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    return Scaffold(
      appBar: AppBar(title: const Text('Palavras Cruzadas')),
      bottomNavigationBar: const _Marca(),
      body: StreamBuilder<List<Perfil>>(
        stream: banco.observarPerfis(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final perfis = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                perfis.isEmpty ? 'Bem-vindo!' : 'Quem vai jogar?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                perfis.isEmpty
                    ? 'Crie um jogador para começar. Ele fica guardado só neste celular.'
                    : 'Toque em Jogar ao lado do seu nome.',
              ),
              const SizedBox(height: 16),
              for (final perfil in perfis)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                    child: Row(
                      children: [
                        Text(
                          perfil.avatar,
                          style: const TextStyle(fontSize: 36),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            perfil.nome,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Jogar'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TelaInicio(perfilId: perfil.id),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Mais opções',
                          onSelected: (_) => _confirmarApagar(context, perfil),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'apagar',
                              child: Text('Apagar jogador'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (perfis.length < Banco.maxPerfis)
                (perfis.isEmpty ? FilledButton.icon : OutlinedButton.icon)(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Novo jogador'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TelaNovoPerfil(),
                    ),
                  ),
                )
              else
                const Text('Este aparelho já tem 5 jogadores.'),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmarApagar(BuildContext context, Perfil perfil) async {
    final banco = Servicos.of(context).banco;
    final apagar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apagar ${perfil.nome}?'),
        content: const Text(
          'Os pontos e as partidas deste jogador também serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (apagar == true) await banco.apagarPerfil(perfil.id);
  }
}

/// Assinatura da Vilela Digit no rodapé da tela de jogadores.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/marca/vilela.png',
              height: 28,
              semanticLabel: 'Logo da Vilela Digit',
            ),
            const SizedBox(width: 8),
            Text('Vilela Digit', style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
