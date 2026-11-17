import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/plano.dart';
import '../telas/tela_premium.dart';

/// Confere o limite de dicas do plano grátis antes de dar uma dica.
/// Devolve o id do jogador se pode dar a dica; null se não pode (e já
/// abriu a tela do Premium explicando).
Future<int?> conferirDica(BuildContext context, int partidaId) async {
  final servicos = Servicos.of(context);
  final partida = await servicos.banco.buscarPartida(partidaId);
  final hoje = await servicos.banco.dicasHoje(partida.perfilId, DateTime.now());
  if (servicos.plano.podeUsarDica(hoje)) return partida.perfilId;
  if (context.mounted) {
    await abrirPremium(
      context,
      motivo:
          'As ${PlanoGratis.dicasPorDia} dicas grátis de hoje já foram usadas. '
          'Amanhã tem mais. Com o Premium, as dicas não têm limite.',
    );
  }
  return null;
}

/// Conta uma dica usada hoje pelo jogador.
Future<void> contarDica(BuildContext context, int perfilId) =>
    Servicos.of(context).banco.contarDica(perfilId, DateTime.now());
