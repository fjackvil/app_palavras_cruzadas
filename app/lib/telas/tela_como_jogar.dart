import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/pontuacao.dart';

/// Uma página do "Como jogar".
class _Pagina {
  const _Pagina(this.emoji, this.titulo, this.itens);

  final String emoji;
  final String titulo;
  final List<String> itens;
}

final _paginas = [
  const _Pagina('👋', 'Bem-vindo!', [
    'Aqui tem dois jogos: palavras cruzadas e caça-palavras.',
    'Tem temas para todas as idades: animais, países, comidas, esportes e muito mais.',
    'Passe para o lado para ver como tudo funciona.',
  ]),
  const _Pagina('🙋', 'Crie seu jogador', [
    'Na primeira tela, toque em "Novo jogador".',
    'Escreva seu nome ou apelido, diga a idade e escolha um desenho ou uma foto sua.',
    'A idade só serve para sugerir o nível. Você pode mudar o nível quando quiser.',
    'Não precisa de conta nem de senha.',
  ]),
  const _Pagina('🎯', 'Escolha o jogo', [
    'Toque em "Jogar" ao lado do seu nome.',
    'Escolha o jogo: Cruzadas ou Caça-palavras.',
    'Escolha o nível: Leve, Médio, Difícil ou Super.',
    'Escolha um ou mais temas, ou deixe "Misturado" para vir de tudo.',
  ]),
  const _Pagina('✏️', 'Palavras cruzadas', [
    'Toque numa casa branca: a palavra fica verde e a dica aparece embaixo.',
    'Digite as letras no teclado. Não precisa de acento: "LEÃO" é LEAO.',
    'Toque numa letra de outra palavra para ver a dica dela. Tocar de novo na mesma casa troca entre horizontal e vertical.',
    'Quando a palavra fica certa, o jogo passa sozinho para a próxima.',
    '"Verificar" mostra em vermelho as letras erradas.',
  ]),
  const _Pagina('🔍', 'Caça-palavras', [
    'As palavras estão escondidas na grade, em qualquer direção: deitadas, em pé, na diagonal e até de trás para a frente.',
    'Arraste o dedo da primeira até a última letra.',
    'Ou toque na primeira letra e depois na última.',
    'A palavra achada ganha uma cor e é riscada na lista.',
  ]),
  _Pagina('⭐', 'Pontos e dicas', [
    'O cronômetro só começa quando você toca na grade.',
    'Cada letra certa vale pontos. Nos níveis mais difíceis vale mais.',
    'Quanto mais rápido, mais pontos. Sem usar dica, ganha um bônus.',
    'A dica ajuda, mas custa pontos: ${Pontuacao.custoDicaLetra} por letra e '
        '${Pontuacao.custoDicaPalavra} pela palavra inteira.',
    'Mandou bem 3 vezes seguidas, rápido e sem dica? O app oferece subir de nível.',
    'Bateu sua maior pontuação ou seu melhor tempo? Aparece "Novo recorde!". Veja todos em "Recordes".',
    'Ganhe medalhas em "Conquistas": primeiro desafio, 7 dias seguidos, 10 sem dica e outras.',
  ]),
  const _Pagina('💾', 'Tudo fica salvo', [
    'O jogo salva sozinho a cada letra. Pode fechar o app sem medo.',
    'Precisa parar? Toque em pausa, ou em "Desistir": nada é apagado.',
    'O desafio vai para "Pendentes" e você continua depois, de onde parou.',
    'Num desafio desistido, dá para "Ver resposta". Aí ele termina sem pontos.',
  ]),
  const _Pagina('📅', 'Desafio do dia', [
    'Todo dia tem uma cruzada e um caça-palavras novos.',
    'É a mesma grade para todo mundo no mesmo nível: dá para comparar com a família e os amigos.',
    'Jogue todo dia para aumentar a sua sequência 🔥.',
    'Terminou? Toque em "Compartilhar resultado" para mandar seus pontos pelo WhatsApp. Só vai o resultado, nunca o seu nome.',
  ]),
  const _Pagina('👨‍👩‍👧‍👦', 'Jogar em família', [
    'Até 5 jogadores no mesmo celular, cada um com seu nível e seus pontos.',
    'As crianças só veem temas próprios para a idade delas.',
    'Cada um toca no seu nome para jogar. Os pontos aparecem na primeira tela.',
    'No "Placar da família" 🏆 dá para ver quem está na frente na semana, e filtrar por jogo, nível e tema.',
    'Tudo fica só neste celular: nada é enviado para a internet.',
  ]),
];

/// "Como jogar": páginas que a pessoa passa com o dedo.
class TelaComoJogar extends StatefulWidget {
  const TelaComoJogar({super.key});

  @override
  State<TelaComoJogar> createState() => _TelaComoJogarState();
}

class _TelaComoJogarState extends State<TelaComoJogar> {
  final _paginador = PageController();
  int _atual = 0;

  @override
  void dispose() {
    _paginador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final ultima = _atual == _paginas.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Como jogar'),
        actions: [
          if (!ultima)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Pular'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _paginador,
                itemCount: _paginas.length,
                onPageChanged: (i) => setState(() => _atual = i),
                itemBuilder: (context, i) {
                  final p = _paginas[i];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    children: [
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: CoresMarca.verdeClaro.withValues(
                              alpha: 0.25,
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p.emoji,
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        p.titulo,
                        textAlign: TextAlign.center,
                        style: texto.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final item in p.itens)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 20,
                                  color: CoresMarca.verde,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(item, style: texto.bodyLarge),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _paginas.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(3),
                    width: i == _atual ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _atual
                          ? CoresMarca.verde
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_atual > 0)
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                      onPressed: () => _paginador.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: Icon(ultima ? Icons.play_arrow : Icons.arrow_forward),
                    label: Text(ultima ? 'Começar a jogar' : 'Próximo'),
                    onPressed: ultima
                        ? () => Navigator.of(context).pop()
                        : () => _paginador.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
