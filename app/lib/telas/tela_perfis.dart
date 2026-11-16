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
      appBar: AppBar(title: const Text('Cruza Letra')),
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
              const Text('Os jogadores ficam guardados só neste celular.'),
              const SizedBox(height: 16),
              for (final perfil in perfis)
                Card(
                  child: ListTile(
                    leading: Text(
                      perfil.avatar,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(perfil.nome),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TelaInicio(perfilId: perfil.id),
                      ),
                    ),
                    onLongPress: () => _confirmarApagar(context, perfil),
                  ),
                ),
              const SizedBox(height: 8),
              if (perfis.length < Banco.maxPerfis)
                FilledButton.icon(
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
