import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/conquistas.dart';
import '../dominio/placar.dart';
import '../dominio/ranking_pessoal.dart';
import '../telas/tela_conquistas.dart';
import '../telas/tela_recordes.dart';
import 'avatar.dart';

/// "Ranking pessoal" da primeira tela: cada jogador contra ele mesmo.
class SecaoRankingPessoal extends StatelessWidget {
  const SecaoRankingPessoal({super.key, required this.perfis});

  final List<Perfil> perfis;

  @override
  Widget build(BuildContext context) {
    if (perfis.isEmpty) return const SizedBox.shrink();
    final texto = Theme.of(context).textTheme;
    return StreamBuilder<List<RegistroPlacar>>(
      stream: Servicos.of(context).banco.observarRegistrosPlacar(),
      builder: (context, s) {
        final todos = s.data ?? const <RegistroPlacar>[];
        final agora = DateTime.now();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              '🏅 Ranking pessoal',
              style: texto.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            for (final p in perfis)
              _CartaoRanking(
                perfil: p,
                mostrarNome: perfis.length > 1,
                ranking: RankingPessoal.de(
                  todos.where((r) => r.perfilId == p.id).toList(),
                  agora,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CartaoRanking extends StatelessWidget {
  const _CartaoRanking({
    required this.perfil,
    required this.mostrarNome,
    required this.ranking,
  });

  final Perfil perfil;
  final bool mostrarNome;
  final RankingPessoal ranking;

  void _abrir(BuildContext context, Widget tela) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => tela));

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final r = ranking;
    final recordes = TelaRecordes(perfil: perfil);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFFFF6DC),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mostrarNome)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    AvatarJogador(avatar: perfil.avatar, raio: 12),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        perfil.nome,
                        style: texto.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                _Numero(
                  valor: '${r.semana}',
                  rotulo: 'pontos na\nsemana',
                  aoTocar: () => _abrir(context, recordes),
                ),
                _Numero(
                  valor: '${r.melhorPartida}',
                  rotulo: 'melhor\npartida',
                  aoTocar: () => _abrir(context, recordes),
                ),
                _Numero(
                  valor: '🔥${r.diasSeguidos}',
                  rotulo: 'dias\nseguidos',
                  aoTocar: () => _abrir(context, recordes),
                ),
                _Numero(
                  valor: '${r.conquistasGanhas}/${conquistas.length}',
                  rotulo: 'conquistas',
                  aoTocar: () =>
                      _abrir(context, TelaConquistas(perfil: perfil)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r.comparacao,
              textAlign: TextAlign.center,
              style: texto.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({
    required this.valor,
    required this.rotulo,
    required this.aoTocar,
  });

  final String valor;
  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  valor,
                  style: texto.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: CoresMarca.verde,
                  ),
                ),
              ),
              Text(rotulo, textAlign: TextAlign.center, style: texto.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
