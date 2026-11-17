import 'nivel.dart';
import 'tema.dart';

/// Compra única que libera tudo para todos os jogadores do aparelho.
const idProdutoPremium = 'premium_familia';

/// Preço mostrado enquanto a loja não responde (o preço de verdade vem do
/// Google Play, já na moeda da pessoa).
const precoPremiumPadrao = r'R$ 9,90';

/// Limites do plano grátis (proposta da especificação, com 2 jogadores
/// para a família poder testar o placar). Premium não tem limites.
abstract final class PlanoGratis {
  static const niveis = {Nivel.leve, Nivel.medio};
  static const maxJogadores = 2;
  static const desafiosPorDia = 3;
  static const dicasPorDia = 3;
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

  /// [hoje]: dicas usadas hoje pelo jogador, nos dois jogos.
  bool podeUsarDica(int hoje) => premium || hoje < PlanoGratis.dicasPorDia;
}
