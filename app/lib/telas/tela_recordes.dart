import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/caca_palavras.dart';
import '../dominio/placar.dart';
import '../dominio/recordes.dart';
import '../dominio/tema.dart';
import '../widgets/avatar.dart';
import 'tela_inicio.dart' show formatarTempo;

/// Recordes pessoais de um jogador: maior pontuação e melhor tempo em cada
/// jogo e nível, e maior pontuação em cada tema jogado sozinho.
class TelaRecordes extends StatelessWidget {
  const TelaRecordes({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final servicos = Servicos.of(context);
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AvatarJogador(avatar: perfil.avatar, raio: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Recordes de ${perfil.nome}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Tema>>(
        future: servicos.temas.carregar(),
        builder: (context, temas) => StreamBuilder<List<RegistroPlacar>>(
          stream: servicos.banco.observarRegistrosPlacar(),
          builder: (context, s) {
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final rec = Recordes.de(
              s.data!.where((r) => r.perfilId == perfil.id).toList(),
            );
            if (rec.desafios == 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    '🏅\n\nTermine um desafio para começar a ter recordes.',
                    textAlign: TextAlign.center,
                    style: texto.titleMedium,
                  ),
                ),
              );
            }
            final nomes = {
              for (final t in temas.data ?? <Tema>[]) t.id: t.nome,
            };
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _Numero(valor: '${rec.desafios}', rotulo: 'desafios'),
                    const SizedBox(width: 12),
                    _Numero(valor: '${rec.pontos}', rotulo: 'pontos'),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Por jogo e nível', style: texto.titleMedium),
                const SizedBox(height: 4),
                for (final n in rec.porNivel)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        n.modo == DesafioCaca.modo
                            ? Icons.search
                            : Icons.grid_on,
                      ),
                      title: Text(
                        '${n.modo == DesafioCaca.modo ? 'Caça-palavras' : 'Cruzadas'}'
                        ' · ${n.nivel.nome}',
                      ),
                      subtitle: Text(
                        '⭐ ${n.maiorPontuacao} pts  ·  '
                        '⏱ ${formatarTempo(n.melhorTempo)}',
                      ),
                      trailing: Text(
                        n.desafios == 1
                            ? '1 desafio'
                            : '${n.desafios} desafios',
                        style: texto.bodySmall,
                      ),
                    ),
                  ),
                if (rec.porTema.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Por tema', style: texto.titleMedium),
                  Text(
                    'Maior pontuação nos desafios de um tema só.',
                    style: texto.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  for (final t in rec.porTema)
                    ListTile(
                      dense: true,
                      title: Text(nomes[t.tema] ?? t.tema),
                      subtitle: Text(
                        t.desafios == 1
                            ? '1 desafio'
                            : '${t.desafios} desafios',
                      ),
                      trailing: Text(
                        '⭐ ${t.maiorPontuacao} pts',
                        style: texto.titleSmall,
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        color: CoresMarca.verdeClaro.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                valor,
                style: texto.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: CoresMarca.verde,
                ),
              ),
              Text(rotulo),
            ],
          ),
        ),
      ),
    );
  }
}
