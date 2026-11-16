import 'caca_palavras.dart';
import 'desafio.dart';
import 'gerador_cruzadas.dart';
import 'nivel.dart';
import 'tema.dart';

/// Desafio diário: a mesma grade para todos no mesmo dia e nível.
///
/// A data vira a semente do gerador e só entram temas infantis, que todos
/// os perfis podem ver. Assim não precisa de servidor.
abstract final class DesafioDiario {
  /// '2026-11-16'
  static String data(DateTime dia) =>
      '${dia.year.toString().padLeft(4, '0')}-'
      '${dia.month.toString().padLeft(2, '0')}-'
      '${dia.day.toString().padLeft(2, '0')}';

  /// 2026111601 (data + número do nível).
  static int semente(String data, Nivel nivel) =>
      int.parse(data.replaceAll('-', '')) * 10 + nivel.index;

  static List<Tema> temas(List<Tema> todos, Nivel nivel) =>
      todos.where((t) => t.infantil && t.disponivelPara(nivel)).toList();

  static DesafioCruzadas gerar(
    List<Tema> todos,
    Nivel nivel,
    DateTime dia, {
    GeradorCruzadas gerador = const GeradorCruzadas(),
  }) {
    final d = data(dia);
    return gerador.gerar(
      temas: temas(todos, nivel),
      nivel: nivel,
      semente: semente(d, nivel),
      diario: d,
    );
  }

  /// Caça-palavras do dia: outra semente, para não repetir as palavras das
  /// cruzadas do mesmo dia.
  static DesafioCaca gerarCaca(List<Tema> todos, Nivel nivel, DateTime dia) {
    final d = data(dia);
    return const GeradorCaca().gerar(
      temas: todos
          .where((t) => t.infantil && temaServeParaCaca(t, nivel))
          .toList(),
      nivel: nivel,
      semente: semente(d, nivel) + 5,
      diario: d,
    );
  }

  /// Quantos dias seguidos o jogador concluiu um desafio diário, contando
  /// até hoje (ou até ontem, se hoje ainda não jogou).
  static int diasSeguidos(Set<String> datasConcluidas, DateTime hoje) {
    var dia = DateTime(hoje.year, hoje.month, hoje.day);
    if (!datasConcluidas.contains(data(dia))) {
      dia = dia.subtract(const Duration(days: 1));
    }
    var seguidos = 0;
    while (datasConcluidas.contains(data(dia))) {
      seguidos++;
      dia = DateTime(dia.year, dia.month, dia.day - 1);
    }
    return seguidos;
  }
}
