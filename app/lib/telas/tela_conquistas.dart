import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/conquistas.dart';
import '../dominio/placar.dart';
import '../widgets/avatar.dart';

/// Medalhas do jogador: as ganhas coloridas, as outras apagadas com o
/// quanto falta.
class TelaConquistas extends StatelessWidget {
  const TelaConquistas({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AvatarJogador(avatar: perfil.avatar, raio: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Conquistas de ${perfil.nome}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<RegistroPlacar>>(
        stream: banco.observarRegistrosPlacar(),
        builder: (context, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meus = s.data!.where((r) => r.perfilId == perfil.id).toList();
          final ganhas = conquistas.where((c) => c.ganhou(meus)).length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '$ganhas de ${conquistas.length} conquistas',
                textAlign: TextAlign.center,
                style: texto.titleLarge,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ganhas / conquistas.length,
                  minHeight: 10,
                  color: CoresMarca.verde,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.95,
                children: [
                  for (final c in conquistas) _Medalha(c: c, registros: meus),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Medalha extends StatelessWidget {
  const _Medalha({required this.c, required this.registros});

  final Conquista c;
  final List<RegistroPlacar> registros;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final feito = c.progresso(registros).clamp(0, c.meta);
    final ganhou = feito >= c.meta;
    return Card(
      color: ganhou ? CoresMarca.amarelo.withValues(alpha: 0.25) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: ganhou ? 1 : 0.3,
              child: Text(c.emoji, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 6),
            Text(
              c.nome,
              textAlign: TextAlign.center,
              style: texto.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              c.descricao,
              textAlign: TextAlign.center,
              style: texto.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (ganhou)
              const Text('✅ Conquistada')
            else ...[
              LinearProgressIndicator(
                value: feito / c.meta,
                color: CoresMarca.verdeClaro,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 2),
              Text('$feito de ${c.meta}', style: texto.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
