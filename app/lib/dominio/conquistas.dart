import 'caca_palavras.dart';
import 'nivel.dart';
import 'placar.dart';

/// Uma medalha local. O progresso é calculado dos desafios concluídos do
/// jogador; nada é guardado à parte.
class Conquista {
  const Conquista({
    required this.id,
    required this.emoji,
    required this.nome,
    required this.descricao,
    required this.meta,
    required this.progresso,
  });

  final String id;
  final String emoji;
  final String nome;
  final String descricao;
  final int meta;

  /// Quanto o jogador já tem (pode passar da meta).
  final int Function(List<RegistroPlacar> registros) progresso;

  bool ganhou(List<RegistroPlacar> registros) => progresso(registros) >= meta;
}

int _contar(List<RegistroPlacar> rs, bool Function(RegistroPlacar) f) =>
    rs.where(f).length;

/// Maior número de dias seguidos com pelo menos um desafio concluído.
int maiorSequenciaDeDias(List<RegistroPlacar> registros) {
  final dias = {
    for (final r in registros)
      DateTime(r.quando.year, r.quando.month, r.quando.day),
  }.toList()..sort();
  var maior = 0;
  var atual = 0;
  DateTime? anterior;
  for (final d in dias) {
    final seguido =
        anterior != null &&
        DateTime(anterior.year, anterior.month, anterior.day + 1) == d;
    atual = seguido ? atual + 1 : 1;
    if (atual > maior) maior = atual;
    anterior = d;
  }
  return maior;
}

/// Todas as conquistas, na ordem em que aparecem na tela.
final conquistas = <Conquista>[
  Conquista(
    id: 'primeiro',
    emoji: '🎉',
    nome: 'Primeiro desafio',
    descricao: 'Termine o seu primeiro desafio.',
    meta: 1,
    progresso: (rs) => rs.length,
  ),
  Conquista(
    id: 'dez',
    emoji: '🔟',
    nome: '10 desafios',
    descricao: 'Termine 10 desafios.',
    meta: 10,
    progresso: (rs) => rs.length,
  ),
  Conquista(
    id: 'cinquenta',
    emoji: '🏆',
    nome: '50 desafios',
    descricao: 'Termine 50 desafios.',
    meta: 50,
    progresso: (rs) => rs.length,
  ),
  Conquista(
    id: 'sem_dica',
    emoji: '🧠',
    nome: '10 sem dica',
    descricao: 'Termine 10 desafios sem usar dica.',
    meta: 10,
    progresso: (rs) => _contar(rs, (r) => r.dicas == 0),
  ),
  Conquista(
    id: 'tres_dias',
    emoji: '🔥',
    nome: '3 dias seguidos',
    descricao: 'Jogue 3 dias seguidos.',
    meta: 3,
    progresso: maiorSequenciaDeDias,
  ),
  Conquista(
    id: 'sete_dias',
    emoji: '📆',
    nome: '7 dias seguidos',
    descricao: 'Jogue 7 dias seguidos.',
    meta: 7,
    progresso: maiorSequenciaDeDias,
  ),
  Conquista(
    id: 'cruzadas',
    emoji: '✏️',
    nome: '10 cruzadas',
    descricao: 'Termine 10 palavras cruzadas.',
    meta: 10,
    progresso: (rs) => _contar(rs, (r) => r.modo != DesafioCaca.modo),
  ),
  Conquista(
    id: 'caca',
    emoji: '🔍',
    nome: '10 caça-palavras',
    descricao: 'Termine 10 caça-palavras.',
    meta: 10,
    progresso: (rs) => _contar(rs, (r) => r.modo == DesafioCaca.modo),
  ),
  Conquista(
    id: 'diario',
    emoji: '📅',
    nome: '5 desafios do dia',
    descricao: 'Termine 5 desafios do dia.',
    meta: 5,
    progresso: (rs) => _contar(rs, (r) => r.temas.isEmpty),
  ),
  Conquista(
    id: 'temas',
    emoji: '🗺️',
    nome: '10 temas',
    descricao: 'Jogue 10 temas diferentes, um de cada vez.',
    meta: 10,
    progresso: (rs) => {
      for (final r in rs)
        if (r.temas.length == 1) r.temas.single,
    }.length,
  ),
  Conquista(
    id: 'dificil',
    emoji: '💪',
    nome: 'Nível Difícil',
    descricao: 'Termine um desafio no nível Difícil.',
    meta: 1,
    progresso: (rs) => _contar(rs, (r) => r.nivel == Nivel.dificil),
  ),
  Conquista(
    id: 'super',
    emoji: '🦸',
    nome: 'Nível Super',
    descricao: 'Termine um desafio no nível Super difícil.',
    meta: 1,
    progresso: (rs) => _contar(rs, (r) => r.nivel == Nivel.superDificil),
  ),
  Conquista(
    id: 'pontos',
    emoji: '⭐',
    nome: '500 pontos',
    descricao: 'Junte 500 pontos, somando todos os desafios.',
    meta: 500,
    progresso: (rs) => rs.fold(0, (s, r) => s + r.pontos),
  ),
];

/// Conquistas que passaram a valer com o desafio [partidaId].
List<Conquista> conquistasNovas(List<RegistroPlacar> doJogador, int partidaId) {
  final antes = doJogador.where((r) => r.partidaId != partidaId).toList();
  return [
    for (final c in conquistas)
      if (c.ganhou(doJogador) && !c.ganhou(antes)) c,
  ];
}
