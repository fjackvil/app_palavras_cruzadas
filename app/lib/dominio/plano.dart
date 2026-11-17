import 'nivel.dart';
import 'tema.dart';

/// Compra única do Premium. Fica ligada à conta Google da Play Store: vale
/// em qualquer celular em que a pessoa entrar com essa conta.
const idProdutoPremium = 'premium';

/// Preço mostrado enquanto a loja não responde (o preço de verdade vem do
/// Google Play, já na moeda da pessoa).
const precoPremiumPadrao = r'R$ 9,90';

/// Limites do plano grátis (proposta da especificação, com 2 jogadores
/// para dar para experimentar o placar). Premium não tem limites.
abstract final class PlanoGratis {
  static const niveis = {Nivel.leve, Nivel.medio};
  static const maxJogadores = 2;
  static const desafiosPorDia = 3;
  static const dicasPorDia = 3;

  /// Desafios começados e não terminados guardados por jogador (fora o
  /// desafio do dia).
  static const maxPendentes = 3;
}

/// O que o aparelho pode usar, conforme tenha o Premium ou não.
class Plano {
  const Plano({required this.premium});

  final bool premium;

  bool nivelLiberado(Nivel n) => premium || PlanoGratis.niveis.contains(n);

  bool temaLiberado(Tema t) => premium || !t.premium;

  /// Nível usado de fato: no grátis, quem está num nível pago joga o Médio.
  Nivel nivelEfetivo(Nivel n) => nivelLiberado(n) ? n : Nivel.medio;

  bool podeCriarJogador(int jogadores) =>
      premium || jogadores < PlanoGratis.maxJogadores;

  /// [hoje]: desafios livres (fora o desafio do dia) começados hoje pelo
  /// jogador, somando cruzadas e caça-palavras.
  bool podeComecarDesafio(int hoje) =>
      premium || hoje < PlanoGratis.desafiosPorDia;

  int? desafiosRestantes(int hoje) => premium
      ? null
      : (PlanoGratis.desafiosPorDia - hoje).clamp(
          0,
          PlanoGratis.desafiosPorDia,
        );

  /// [pendentes]: desafios livres do jogador em andamento ou desistidos.
  bool podeGuardarPendente(int pendentes) =>
      premium || pendentes < PlanoGratis.maxPendentes;

  /// [hoje]: dicas usadas hoje pelo jogador, nos dois jogos.
  bool podeUsarDica(int hoje) => premium || hoje < PlanoGratis.dicasPorDia;
}
