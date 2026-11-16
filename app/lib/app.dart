import 'package:material_ui/material_ui.dart';

import 'dados/banco.dart';
import 'dominio/tema.dart';
import 'telas/tela_perfis.dart';

/// Cores da marca Vilela Digit (do ícone em docs/marca).
abstract final class CoresMarca {
  static const verde = Color(0xFF329932);
  static const verdeClaro = Color(0xFF66CC39);
  static const amarelo = Color(0xFFE9B320);
  static const vermelho = Color(0xFFFC0101);
}

/// Dá acesso ao banco e aos temas em qualquer tela.
class Servicos extends InheritedWidget {
  const Servicos({
    super.key,
    required this.banco,
    required this.temas,
    required super.child,
  });

  final Banco banco;
  final RepositorioTemas temas;

  static Servicos of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Servicos>()!;

  @override
  bool updateShouldNotify(Servicos oldWidget) =>
      banco != oldWidget.banco || temas != oldWidget.temas;
}

class CruzaLetraApp extends StatelessWidget {
  const CruzaLetraApp({super.key, required this.banco, required this.temas});

  final Banco banco;
  final RepositorioTemas temas;

  @override
  Widget build(BuildContext context) {
    return Servicos(
      banco: banco,
      temas: temas,
      child: MaterialApp(
        title: 'Cruza Letra',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: CoresMarca.verde),
          useMaterial3: true,
        ),
        home: const TelaPerfis(),
      ),
    );
  }
}
