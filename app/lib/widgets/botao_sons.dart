import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/sons.dart';

/// Liga e desliga os sons e a vibração do fim de jogo.
class BotaoSons extends StatefulWidget {
  const BotaoSons({super.key});

  @override
  State<BotaoSons> createState() => _BotaoSonsState();
}

class _BotaoSonsState extends State<BotaoSons> {
  bool? _ligados;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ligados == null) {
      Sons.ligados(Servicos.of(context).banco).then((v) {
        if (mounted) setState(() => _ligados = v);
      });
    }
  }

  Future<void> _trocar() async {
    final novo = !(_ligados ?? true);
    await Sons.ligar(Servicos.of(context).banco, ligado: novo);
    if (!mounted) return;
    setState(() => _ligados = novo);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            novo
                ? '🔊 Sons ligados. No modo silencioso ou vibrar, o celular só vibra.'
                : '🔇 Sons e vibração desligados.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ligados = _ligados ?? true;
    return IconButton(
      tooltip: ligados ? 'Desligar sons' : 'Ligar sons',
      icon: Icon(ligados ? Icons.volume_up_rounded : Icons.volume_off_rounded),
      onPressed: _ligados == null ? null : _trocar,
    );
  }
}
