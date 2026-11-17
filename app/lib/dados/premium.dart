import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../dominio/plano.dart';
import 'banco.dart';

/// Cuida do Premium: pergunta ao Google Play se a conta do aparelho já
/// comprou, faz a compra e guarda uma cópia no banco para funcionar sem
/// internet. Nenhum dado do jogador é enviado: só o pedido de compra, que o
/// próprio Google Play trata.
class ServicoPremium extends ChangeNotifier {
  ServicoPremium(this._banco, {this.loja, this.usarLoja = true});

  static const _chaveCopia = 'premium';

  final Banco _banco;

  /// Loja de compras; nulo = a do Google Play.
  final InAppPurchase? loja;

  /// false nos testes (não fala com o Google Play).
  final bool usarLoja;

  bool _premium = false;
  bool _lojaDisponivel = false;
  bool _comprando = false;
  String _preco = precoPremiumPadrao;
  String? _aviso;
  ProductDetails? _produto;
  StreamSubscription<List<PurchaseDetails>>? _assinatura;

  bool get premium => _premium;
  Plano get plano => Plano(premium: _premium);

  /// Preço vindo da loja (na moeda da pessoa) ou o padrão.
  String get preco => _preco;

  /// A loja respondeu e o produto existe: dá para comprar.
  bool get podeComprar => _lojaDisponivel && _produto != null;
  bool get comprando => _comprando;

  /// Última mensagem para mostrar (erro ou confirmação); lida uma vez.
  String? tirarAviso() {
    final a = _aviso;
    _aviso = null;
    return a;
  }

  InAppPurchase get _l => loja ?? InAppPurchase.instance;

  /// Lê a cópia local e, se houver loja, confere as compras da conta.
  Future<void> iniciar() async {
    _premium = await _banco.lerAjuste(_chaveCopia) == '1';
    notifyListeners();
    if (!usarLoja) return;
    try {
      _lojaDisponivel = await _l.isAvailable();
      if (!_lojaDisponivel) return;
      _assinatura = _l.purchaseStream.listen(
        _aoAtualizarCompras,
        onError: (Object _) {},
      );
      final resposta = await _l.queryProductDetails({idProdutoPremium});
      if (resposta.productDetails.isNotEmpty) {
        _produto = resposta.productDetails.first;
        _preco = _produto!.price;
      }
      notifyListeners();
      // Traz de volta a compra feita antes (outro celular, reinstalação).
      await _l.restorePurchases();
    } on Object {
      // Sem loja (emulador sem Play Store, sem conta): fica com a cópia.
      _lojaDisponivel = false;
      notifyListeners();
    }
  }

  Future<void> comprar() async {
    final produto = _produto;
    if (produto == null || _comprando) {
      _aviso =
          'A compra ainda não está disponível. Confira se o Google Play está '
          'instalado e com uma conta Google.';
      notifyListeners();
      return;
    }
    _comprando = true;
    notifyListeners();
    try {
      await _l.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: produto),
      );
    } on Object {
      _comprando = false;
      _aviso = 'Não deu para abrir a compra. Tente de novo.';
      notifyListeners();
    }
  }

  Future<void> restaurar() async {
    if (!_lojaDisponivel) {
      _aviso = 'O Google Play não respondeu. Tente de novo mais tarde.';
      notifyListeners();
      return;
    }
    _aviso = 'Procurando compras desta conta Google...';
    notifyListeners();
    await _l.restorePurchases();
  }

  Future<void> _aoAtualizarCompras(List<PurchaseDetails> compras) async {
    for (final c in compras) {
      if (c.productID != idProdutoPremium) continue;
      switch (c.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _ativar(true);
          _aviso = c.status == PurchaseStatus.purchased
              ? 'Premium liberado! Obrigado por apoiar o app. 💚'
              : 'Premium recuperado.';
        case PurchaseStatus.pending:
          _aviso =
              'Compra aguardando aprovação (por exemplo, dos pais no Family '
              'Link). O Premium libera sozinho quando for aprovada.';
        case PurchaseStatus.error:
          _aviso = 'A compra não foi concluída.';
        case PurchaseStatus.canceled:
          break;
      }
      if (c.pendingCompletePurchase) await _l.completePurchase(c);
    }
    _comprando = false;
    notifyListeners();
  }

  Future<void> _ativar(bool sim) async {
    _premium = sim;
    await _banco.gravarAjuste(_chaveCopia, sim ? '1' : '0');
    notifyListeners();
  }

  /// Só em versão de teste (debug): liga e desliga o Premium sem comprar,
  /// para conferir os bloqueios.
  Future<void> simular(bool sim) async {
    if (!kDebugMode) return;
    await _ativar(sim);
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }
}
