import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'dados/banco.dart';
import 'dados/premium.dart';
import 'dominio/plano.dart';
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
    required this.premium,
    required this.ehPremium,
    required super.child,
  });

  final Banco banco;
  final RepositorioTemas temas;
  final ServicoPremium premium;

  /// Cópia do estado no momento: as telas se redesenham quando muda.
  final bool ehPremium;

  /// O que o aparelho pode usar agora (grátis ou Premium).
  Plano get plano => Plano(premium: ehPremium);

  static Servicos of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Servicos>()!;

  @override
  bool updateShouldNotify(Servicos oldWidget) =>
      banco != oldWidget.banco ||
      temas != oldWidget.temas ||
      ehPremium != oldWidget.ehPremium;
}

class PalavrasCruzadasApp extends StatefulWidget {
  const PalavrasCruzadasApp({
    super.key,
    required this.banco,
    required this.temas,
    this.premium,
  });

  final Banco banco;
  final RepositorioTemas temas;

  /// Nos testes vem um serviço sem loja; no app, um de verdade.
  final ServicoPremium? premium;

  @override
  State<PalavrasCruzadasApp> createState() => _PalavrasCruzadasAppState();
}

class _PalavrasCruzadasAppState extends State<PalavrasCruzadasApp> {
  late final ServicoPremium _premium =
      widget.premium ?? (ServicoPremium(widget.banco)..iniciar());

  @override
  void dispose() {
    if (widget.premium == null) _premium.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _premium,
      builder: (context, _) => Servicos(
        banco: widget.banco,
        temas: widget.temas,
        premium: _premium,
        ehPremium: _premium.premium,
        child: MaterialApp(
          title: 'Palavras Cruzadas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: CoresMarca.verde),
            useMaterial3: true,
          ),
          builder: (context, tela) => BarraDoSistema(child: tela!),
          home: const TelaPerfis(),
        ),
      ),
    );
  }
}

/// Desde o Android 15 o app desenha por baixo da barra de navegação (os
/// botões voltar, início e recentes, ou a barrinha de gestos). Isto reserva
/// esse espaço embaixo e nas laterais para todas as telas e janelas, com um
/// fundo claro e ícones escuros na barra, como era antes.
class BarraDoSistema extends StatelessWidget {
  const BarraDoSistema({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ColoredBox(
        color: cores.surface,
        child: SafeArea(top: false, child: child),
      ),
    );
  }
}
