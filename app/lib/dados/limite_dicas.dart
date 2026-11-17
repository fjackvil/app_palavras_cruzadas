import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/plano.dart';
import '../telas/tela_premium.dart';

/// Confere o limite de dicas do plano grátis (por celular) antes de dar
/// uma dica. Devolve true se pode; false se não pode (e já abriu a tela do
/// Premium explicando).
Future<bool> conferirDica(BuildContext context) async {
  final servicos = Servicos.of(context);
  final hoje = await servicos.banco.dicasHoje(DateTime.now());
  if (servicos.plano.podeUsarDica(hoje)) return true;
  if (context.mounted) {
    await abrirPremium(
      context,
      motivo:
          'As ${PlanoGratis.dicasPorDia} dicas grátis de hoje deste celular já '
          'foram usadas. '
          'Amanhã tem mais. Com o Premium, as dicas não têm limite.',
    );
  }
  return false;
}

/// Conta uma dica usada hoje no aparelho.
Future<void> contarDica(BuildContext context) =>
    Servicos.of(context).banco.contarDica(DateTime.now());
