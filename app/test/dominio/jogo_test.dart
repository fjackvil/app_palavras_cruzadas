import 'package:palavras_cruzadas/dominio/desafio.dart';
import 'package:palavras_cruzadas/dominio/jogo_cruzadas.dart';
import 'package:palavras_cruzadas/dominio/nivel.dart';
import 'package:flutter_test/flutter_test.dart';

/// Grade fixa:  G A T O
///              . . . V
///              . . . A
DesafioCruzadas desafio(Nivel nivel) => DesafioCruzadas(
  tamanho: 4,
  nivel: nivel,
  temas: const ['teste'],
  semente: 1,
  palavras: const [
    PalavraNaGrade(
      resposta: 'GATO',
      escrita: 'GATO',
      dica: 'Mia',
      linha: 0,
      coluna: 0,
      horizontal: true,
      numero: 1,
    ),
    PalavraNaGrade(
      resposta: 'OVA',
      escrita: 'OVA',
      dica: 'Ovos de peixe',
      linha: 0,
      coluna: 3,
      horizontal: false,
      numero: 2,
    ),
  ],
);

void digitarTudo(JogoCruzadas jogo, String texto) {
  for (final letra in texto.split('')) {
    jogo.digitar(letra);
  }
}

void main() {
  test('no Médio digita e avança dentro da palavra até concluir', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    expect((jogo.linha, jogo.coluna, jogo.horizontal), (0, 0, true));
    digitarTudo(jogo, 'GATO');
    expect(jogo.respostas.take(4).join(), 'GATO');
    expect(jogo.concluido, isFalse);

    jogo.tocar(1, 3);
    expect(jogo.horizontal, isFalse);
    digitarTudo(jogo, 'VA');
    expect(jogo.concluido, isTrue);
    expect(jogo.pontuacao.bonusSemDica, greaterThan(0));
  });

  test('no Leve a primeira letra de cada palavra já vem escrita', () {
    final jogo = JogoCruzadas(desafio(Nivel.leve));
    expect(jogo.respostas[0], 'G');
    expect(jogo.respostas[3], 'O');
    // Começa na primeira casa livre.
    expect((jogo.linha, jogo.coluna), (0, 1));
    digitarTudo(jogo, 'AT');
    expect(jogo.respostas.take(4).join(), 'GATO');
    // A letra fixa não pode ser apagada.
    jogo.tocar(0, 0);
    jogo.apagar();
    expect(jogo.respostas[0], 'G');
  });

  test('tocar duas vezes num cruzamento troca a direção', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    jogo.tocar(0, 3);
    final antes = jogo.horizontal;
    jogo.tocar(0, 3);
    expect(jogo.horizontal, !antes);
  });

  test('verificar marca as letras erradas', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    digitarTudo(jogo, 'GOTA');
    expect(jogo.verificarPalavra(), isFalse);
    expect(jogo.erradas, {1, 3});
    jogo.tocar(0, 1);
    jogo.digitar('A');
    expect(jogo.erradas, {3});
  });

  test('dicas revelam letra e palavra e são contadas', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    jogo.dicaDeLetra();
    expect(jogo.respostas[0], 'G');
    expect(jogo.dicasLetra, 1);
    jogo.dicaDePalavra();
    expect(jogo.respostas.take(4).join(), 'GATO');
    expect(jogo.dicasPalavra, 1);
    expect(jogo.pontuacao.bonusSemDica, 0);
  });

  test('salvar e retomar mantém letras, dicas e tempo', () {
    final d = desafio(Nivel.medio);
    final jogo = JogoCruzadas(d);
    digitarTudo(jogo, 'GA');
    jogo.dicaDeLetra();
    jogo.contarSegundo();
    final volta = JogoCruzadas.deJson(d, jogo.paraJson());
    expect(volta.respostas, jogo.respostas);
    expect(volta.reveladas, jogo.reveladas);
    expect(volta.dicasLetra, 1);
    expect(volta.segundos, 1);
  });

  test('palavra certa passa sozinha para a próxima que falta', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    digitarTudo(jogo, 'GATO');
    // Foi para OVA, na primeira casa que falta (a do V).
    expect(jogo.horizontal, isFalse);
    expect((jogo.linha, jogo.coluna), (1, 3));
  });

  test('palavra errada não avança; verificar certa avança', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    digitarTudo(jogo, 'GATA');
    expect(jogo.horizontal, isTrue);
    expect(jogo.verificarPalavra(), isFalse);
    jogo.tocar(0, 3);
    if (!jogo.horizontal) jogo.tocar(0, 3);
    jogo.digitar('O');
    expect(jogo.horizontal, isFalse);
    expect((jogo.linha, jogo.coluna), (1, 3));
  });

  test('ao retomar começa pela primeira palavra que falta', () {
    final d = desafio(Nivel.medio);
    final jogo = JogoCruzadas(d);
    digitarTudo(jogo, 'GATO');
    final volta = JogoCruzadas.deJson(d, jogo.paraJson());
    expect(volta.horizontal, isFalse);
    expect((volta.linha, volta.coluna), (1, 3));
  });

  test('ver resposta completa a grade e marca o que faltava', () {
    final jogo = JogoCruzadas(desafio(Nivel.medio));
    digitarTudo(jogo, 'GAT');
    jogo.revelarTudo();
    expect(jogo.concluido, isTrue);
    // O, V e A que faltavam ficam marcadas como reveladas (azul).
    expect(jogo.reveladas, {3, 7, 11});
    expect(jogo.reveladas.contains(0), isFalse);
  });
}
