import 'dart:async';

import 'dart:convert';

import 'package:crypto/crypto.dart';
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
  static const _chaveRevisor = 'premium_revisor';

  /// Código de revisor do Google Play: libera o Premium só neste aparelho,
  /// para a equipe de análise ver tudo (ela não pode comprar). O código em
  /// si fica só na Play Console (Detalhes do login) e no arquivo local
  /// `codigo-revisor.txt`, fora do Git; aqui guardamos só o SHA-256 dele
  /// com um sal, para não dar para ler o código dentro do app. Para trocar,
  /// gere outro código, sal e hash juntos.
  static const _salRevisor = '3e013e8175ec77e5';
  static const _hashRevisor =
      '3f26d7b934d8fdc649082dfb1a8a4914171ac6b69cb436c9c1a092510bea02d5';

  /// Confere o código de revisor (sem diferença entre maiúsculas e
  /// minúsculas, ignorando espaços e hífens).
  static bool codigoRevisorValido(String codigo) {
    final limpo = codigo.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    final hash = sha256.convert(utf8.encode('$_salRevisor$limpo'));
    return hash.toString() == _hashRevisor;
  }

  /// Versão de teste com tudo liberado, só para o desenvolvedor instalar
  /// no próprio celular. Gerada com
  /// `flutter build apk --release --dart-define=PREMIUM_LIBERADO=true`.
  /// NUNCA enviar esse pacote para a Play Store: o pacote da loja é o .aab,
  /// gerado sem essa opção.
  static const liberadoParaTeste = bool.fromEnvironment('PREMIUM_LIBERADO');

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
    if (liberadoParaTeste) {
      // Não fala com a loja nem grava nada: só libera tudo nesta instalação.
      _premium = true;
      notifyListeners();
      return;
    }
    _premium =
        await _banco.lerAjuste(_chaveCopia) == '1' ||
        await _banco.lerAjuste(_chaveRevisor) == '1';
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

  /// Libera o Premium neste aparelho se o código de revisor estiver certo.
  /// Fica guardado à parte da compra: a conferência com o Google Play não
  /// o desliga.
  Future<bool> usarCodigoRevisor(String codigo) async {
    if (!codigoRevisorValido(codigo)) return false;
    await _banco.gravarAjuste(_chaveRevisor, '1');
    _premium = true;
    notifyListeners();
    return true;
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
