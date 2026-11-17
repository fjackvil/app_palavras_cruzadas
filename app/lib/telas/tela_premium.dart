import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/premium.dart';
import '../dominio/plano.dart';

/// Abre a tela "Seja Premium". [motivo] explica o que estava bloqueado.
Future<void> abrirPremium(BuildContext context, {String? motivo}) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TelaPremium(motivo: motivo)),
    );

/// Compra única que libera tudo. Fica na conta Google da Play Store.
class TelaPremium extends StatefulWidget {
  const TelaPremium({super.key, this.motivo});

  final String? motivo;

  @override
  State<TelaPremium> createState() => _TelaPremiumState();
}

class _TelaPremiumState extends State<TelaPremium> {
  void _mostrarAviso() {
    final aviso = Servicos.of(context).premium.tirarAviso();
    if (aviso == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(aviso)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicos = Servicos.of(context);
    final premium = servicos.premium;
    final texto = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: premium,
      builder: (context, _) {
        _mostrarAviso();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: CoresMarca.verde,
            foregroundColor: Colors.white,
            title: const Text('Premium'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Center(child: Text('⭐', style: TextStyle(fontSize: 64))),
              const SizedBox(height: 8),
              Text(
                premium.premium ? 'Premium ativo!' : 'Libere tudo, para sempre',
                textAlign: TextAlign.center,
                style: texto.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                premium.premium
                    ? 'Obrigado por apoiar o app. Tudo está liberado.'
                    : 'Uma compra só, sem mensalidade. Ela fica na sua conta '
                          'Google: vale em qualquer celular em que você entrar '
                          'com essa conta na Play Store.',
                textAlign: TextAlign.center,
              ),
              if (widget.motivo != null && !premium.premium) ...[
                const SizedBox(height: 16),
                Card(
                  color: CoresMarca.amarelo.withValues(alpha: 0.25),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Text('🔒', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(widget.motivo!)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _Comparacao(texto: texto),
              const SizedBox(height: 20),
              if (ServicoPremium.liberadoParaTeste)
                const Center(
                  child: Chip(
                    avatar: Text('🧪'),
                    label: Text('Versão de teste: Premium liberado sem compra'),
                  ),
                )
              else if (premium.premium)
                const Center(
                  child: Chip(
                    avatar: Icon(Icons.check_circle, color: CoresMarca.verde),
                    label: Text('Premium ativo nesta conta Google'),
                  ),
                )
              else ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    textStyle: texto.titleLarge,
                  ),
                  onPressed: premium.comprando ? null : premium.comprar,
                  child: premium.comprando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Text('Comprar por ${premium.preco}'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: premium.restaurar,
                  child: const Text('Já comprei: restaurar compra'),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'O pagamento é feito pelo Google Play (cartão, Pix ou saldo). '
                'Nós não recebemos seus dados de pagamento. Em contas de '
                'criança (Family Link), o Google pede a aprovação dos pais. '
                'Trocou de celular? Use a mesma conta Google e toque em '
                '"restaurar compra".',
                textAlign: TextAlign.center,
                style: texto.bodySmall,
              ),
              if (kDebugMode) ...[
                const Divider(height: 32),
                Text(
                  'Só na versão de teste:',
                  textAlign: TextAlign.center,
                  style: texto.bodySmall,
                ),
                TextButton(
                  onPressed: () => premium.simular(!premium.premium),
                  child: Text(
                    premium.premium ? 'Simular grátis' : 'Simular Premium',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Comparacao extends StatelessWidget {
  const _Comparacao({required this.texto});

  final TextTheme texto;

  @override
  Widget build(BuildContext context) {
    final linhas = [
      ('Níveis', 'Leve e Médio', 'Todos, até o Super'),
      ('Temas', '1 por categoria', 'Todos os 64'),
      ('Desafios por dia', '${PlanoGratis.desafiosPorDia}', 'Sem limite'),
      ('Dicas por dia', '${PlanoGratis.dicasPorDia}', 'Sem limite'),
      ('Jogadores', '${PlanoGratis.maxJogadores}', 'Até 5'),
      ('Desafio do dia', 'Sim', 'Sim'),
      ('Anúncios', 'Nenhum', 'Nenhum'),
    ];
    final negrito = texto.labelLarge?.copyWith(fontWeight: FontWeight.w800);
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.3)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300),
      ),
      children: [
        TableRow(
          children: [
            const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Grátis', style: negrito),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Premium ⭐',
                style: negrito?.copyWith(color: CoresMarca.verde),
              ),
            ),
          ],
        ),
        for (final (item, gratis, premium) in linhas)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item, style: texto.bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(gratis, style: texto.bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  premium,
                  style: texto.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
