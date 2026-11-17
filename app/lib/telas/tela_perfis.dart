import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/nivel.dart';
import '../dominio/plano.dart';
import '../widgets/avatar.dart';
import '../widgets/cabecalho_cruzado.dart';
import 'tela_como_jogar.dart';
import '../widgets/icones_jogo.dart';
import 'tela_desafio_dia.dart';
import 'tela_inicio.dart';
import 'tela_placar.dart';
import 'tela_premium.dart';
import 'tela_sobre.dart';
import 'tela_novo_perfil.dart';

/// Cores dos círculos dos avatares, em rodízio pelo id do jogador.
const _coresAvatar = [
  Color(0xFFFFE08A),
  Color(0xFFB9E8A0),
  Color(0xFFA8D8F5),
  Color(0xFFF9B8B8),
  Color(0xFFD6C2F2),
];

/// Tela de abertura, "Quem vai jogar?": lista os jogadores do aparelho.
class TelaPerfis extends StatelessWidget {
  const TelaPerfis({super.key});

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final plano = Servicos.of(context).plano;
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const _Marca(),
      body: StreamBuilder<List<Perfil>>(
        stream: banco.observarPerfis(),
        builder: (context, snapshot) {
          final perfis = snapshot.data;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const CabecalhoCruzado(
                subtitulo: 'Cruzadas e caça-palavras para toda a família',
              ),
              const SizedBox(height: 16),
              _Destaques(perfis: perfis ?? const []),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: perfis == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            perfis.isEmpty ? 'Bem-vindo!' : 'Quem vai jogar?',
                            style: texto.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            perfis.isEmpty
                                ? 'Crie um jogador para começar. Ele fica '
                                      'guardado só neste celular.'
                                : 'Toque em Jogar ao lado do seu nome.',
                          ),
                          const SizedBox(height: 12),
                          for (final perfil in perfis)
                            _CartaoJogador(
                              perfil: perfil,
                              aoApagar: () => _confirmarApagar(context, perfil),
                            ),
                          const SizedBox(height: 8),
                          if (perfis.length < Banco.maxPerfis)
                            (perfis.isEmpty
                                ? FilledButton.icon
                                : OutlinedButton.icon)(
                              style: perfis.isEmpty
                                  ? FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(56),
                                      textStyle: texto.titleLarge,
                                    )
                                  : null,
                              icon: Icon(
                                plano.podeCriarJogador(perfis.length)
                                    ? Icons.person_add
                                    : Icons.lock_outline,
                              ),
                              label: Text(
                                plano.podeCriarJogador(perfis.length)
                                    ? 'Novo jogador'
                                    : 'Novo jogador (Premium)',
                              ),
                              onPressed: () =>
                                  plano.podeCriarJogador(perfis.length)
                                  ? Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const TelaNovoPerfil(),
                                      ),
                                    )
                                  : abrirPremium(
                                      context,
                                      motivo:
                                          'No plano grátis são até '
                                          '${PlanoGratis.maxJogadores} jogadores. '
                                          'Com o Premium, até ${Banco.maxPerfis}.',
                                    ),
                            )
                          else
                            const Text('Este aparelho já tem 5 jogadores.'),
                          if (mostrarPlacarFamilia && perfis.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.emoji_events_outlined),
                              label: const Text('Placar da família'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const TelaPlacar(),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          _BotaoPremium(premium: plano.premium),
                          const SizedBox(height: 8),
                          (perfis.isEmpty
                              ? FilledButton.tonalIcon
                              : TextButton.icon)(
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Como jogar'),
                            onPressed: () => abrirComoJogar(context),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmarApagar(BuildContext context, Perfil perfil) async {
    final banco = Servicos.of(context).banco;
    final apagar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apagar ${perfil.nome}?'),
        content: const Text(
          'Os pontos e as partidas deste jogador também serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (apagar == true) {
      await banco.apagarPerfil(perfil.id);
      await Avatar.apagarFoto(perfil.avatar);
    }
  }
}

/// Assinatura da Vilela Digit no rodapé da tela de jogadores.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    // Tocar no rodapé abre "Sobre e privacidade".
    return SafeArea(
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const TelaSobre())),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/marca/vilela.png',
                height: 28,
                semanticLabel: 'Logo da Vilela Digit',
              ),
              const SizedBox(width: 8),
              Text('Vilela Digit', style: texto.titleSmall),
              Text('  ·  ', style: texto.bodySmall),
              const Icon(Icons.lock_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                'Sobre e privacidade',
                style: texto.bodySmall?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Os três jeitos de jogar, logo abaixo do cabeçalho. Tocar num deles abre
/// o jogo: direto, se só há um jogador; perguntando quem vai jogar, se há
/// vários; ou no cadastro, se ainda não há nenhum.
class _Destaques extends StatelessWidget {
  const _Destaques({required this.perfis});

  final List<Perfil> perfis;

  Future<void> _abrir(BuildContext context, Modo? modo) async {
    final navegador = Navigator.of(context);
    if (perfis.isEmpty) {
      await navegador.push(
        MaterialPageRoute<void>(builder: (_) => const TelaNovoPerfil()),
      );
      return;
    }
    final perfil = perfis.length == 1
        ? perfis.single
        : await showModalBottomSheet<Perfil>(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text(
                      'Quem vai jogar?',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final p in perfis)
                    ListTile(
                      leading: AvatarJogador(avatar: p.avatar, raio: 20),
                      title: Text(p.nome),
                      onTap: () => Navigator.pop(context, p),
                    ),
                ],
              ),
            ),
          );
    if (perfil == null) return;
    await navegador.push(
      MaterialPageRoute<void>(
        // Cartão "Desafio do dia" (modo nulo) abre a tela própria do dia.
        builder: (_) => modo == null
            ? TelaDesafioDia(perfilId: perfil.id)
            : TelaInicio(perfilId: perfil.id, modoInicial: modo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itens = <(Widget, String, Modo?)>[
      (const IconeCruzadas(), 'Cruzadas', Modo.cruzadas),
      (const IconeCaca(), 'Caça-palavras', Modo.caca),
      (
        const Text('📅', style: TextStyle(fontSize: 30)),
        'Desafio do dia',
        null,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final (icone, nome, modo) in itens)
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _abrir(context, modo),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        SizedBox(height: 38, child: Center(child: icone)),
                        const SizedBox(height: 6),
                        Text(
                          nome,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Um jogador: avatar num círculo colorido, nome, nível, pontos e Jogar.
class _CartaoJogador extends StatelessWidget {
  const _CartaoJogador({required this.perfil, required this.aoApagar});

  final Perfil perfil;
  final VoidCallback aoApagar;

  Future<void> _trocarAvatar(BuildContext context) async {
    final banco = Servicos.of(context).banco;
    final novo = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto ou avatar de ${perfil.nome}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              EscolhaAvatar(
                atual: perfil.avatar,
                aoEscolher: (a) => Navigator.pop(context, a),
              ),
            ],
          ),
        ),
      ),
    );
    if (novo == null || novo == perfil.avatar) return;
    await banco.mudarAvatar(perfil.id, novo);
    await Avatar.apagarFoto(perfil.avatar);
  }

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    final texto = Theme.of(context).textTheme;
    void jogar() => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TelaInicio(perfilId: perfil.id)),
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: jogar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
          child: Row(
            children: [
              AvatarJogador(
                avatar: perfil.avatar,
                fundo: _coresAvatar[perfil.id % _coresAvatar.length],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perfil.nome,
                      style: texto.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    StreamBuilder<int>(
                      stream: banco.observarTotalPontos(perfil.id),
                      builder: (context, s) => Text(
                        '${Nivel.porNome(perfil.nivelAtual).nome} · '
                        '⭐ ${s.data ?? 0} pontos',
                        style: texto.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Jogar'),
                onPressed: jogar,
              ),
              PopupMenuButton<String>(
                tooltip: 'Mais opções',
                onSelected: (opcao) =>
                    opcao == 'avatar' ? _trocarAvatar(context) : aoApagar(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'avatar',
                    child: Text('Trocar foto ou avatar'),
                  ),
                  PopupMenuItem(value: 'apagar', child: Text('Apagar jogador')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void abrirComoJogar(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TelaComoJogar()));

/// "Seja Premium" (ou o selo de Premium ativo), na primeira tela.
class _BotaoPremium extends StatelessWidget {
  const _BotaoPremium({required this.premium});

  final bool premium;

  @override
  Widget build(BuildContext context) {
    if (premium) {
      return Center(
        child: TextButton.icon(
          icon: const Text('⭐'),
          label: const Text('Premium ativo'),
          onPressed: () => abrirPremium(context),
        ),
      );
    }
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: CoresMarca.amarelo,
        foregroundColor: const Color(0xFF1B2A1B),
        minimumSize: const Size.fromHeight(48),
      ),
      icon: const Text('⭐', style: TextStyle(fontSize: 18)),
      label: Text(
        'Seja Premium: libere tudo por ${Servicos.of(context).premium.preco}',
      ),
      onPressed: () => abrirPremium(context),
    );
  }
}
