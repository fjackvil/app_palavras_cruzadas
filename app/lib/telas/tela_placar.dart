import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dados/banco.dart';
import '../dominio/caca_palavras.dart';
import '../dominio/nivel.dart';
import '../dominio/placar.dart';
import '../dominio/tema.dart';
import '../widgets/avatar.dart';

/// Placar da família: ranking entre os jogadores do aparelho, por semana,
/// jogo, nível e tema. Tudo calculado no celular.
class TelaPlacar extends StatefulWidget {
  const TelaPlacar({super.key});

  @override
  State<TelaPlacar> createState() => _TelaPlacarState();
}

class _TelaPlacarState extends State<TelaPlacar> {
  FiltroPlacar _filtro = const FiltroPlacar();
  Future<List<Tema>>? _temas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _temas ??= Servicos.of(context).temas.carregar();
  }

  @override
  Widget build(BuildContext context) {
    final banco = Servicos.of(context).banco;
    return Scaffold(
      appBar: AppBar(title: const Text('Placar da família')),
      body: StreamBuilder<List<Perfil>>(
        stream: banco.observarPerfis(),
        builder: (context, perfis) => StreamBuilder<List<RegistroPlacar>>(
          stream: banco.observarRegistrosPlacar(),
          builder: (context, registros) {
            if (!perfis.hasData || !registros.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final porId = {for (final p in perfis.data!) p.id: p};
            final linhas = Placar.calcular(
              perfis: porId.keys.toList(),
              registros: registros.data!,
              filtro: _filtro,
              agora: DateTime.now(),
            );
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _filtros(context),
                const SizedBox(height: 16),
                if (linhas.every((l) => l.pontos == 0))
                  _vazio(context)
                else
                  for (final l in linhas)
                    _Linha(linha: l, perfil: porId[l.perfilId]!),
                const SizedBox(height: 12),
                Text(
                  _filtro.soEstaSemana
                      ? 'A semana começa na segunda-feira. Só contam os '
                            'desafios terminados.'
                      : 'Só contam os desafios terminados.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filtros(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true, label: Text('Esta semana')),
            ButtonSegment(value: false, label: Text('Desde o início')),
          ],
          selected: {_filtro.soEstaSemana},
          onSelectionChanged: (s) =>
              setState(() => _filtro = _filtro.copiar(soEstaSemana: s.first)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (modo, nome) in const [
              (null, 'Os dois jogos'),
              ('cruzadas', 'Cruzadas'),
              (DesafioCaca.modo, 'Caça-palavras'),
            ])
              ChoiceChip(
                label: Text(nome),
                selected: _filtro.modo == modo,
                onSelected: (_) =>
                    setState(() => _filtro = _filtro.copiar(modo: () => modo)),
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final nivel in <Nivel?>[null, ...Nivel.values])
              ChoiceChip(
                label: Text(nivel?.nomeCurto ?? 'Todos os níveis'),
                selected: _filtro.nivel == nivel,
                onSelected: (_) => setState(
                  () => _filtro = _filtro.copiar(nivel: () => nivel),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        FutureBuilder<List<Tema>>(
          future: _temas,
          builder: (context, s) {
            final temas = s.data ?? const <Tema>[];
            return DropdownButtonFormField<String?>(
              initialValue: _filtro.tema,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Tema',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                for (final t in temas)
                  DropdownMenuItem(value: t.id, child: Text(t.nome)),
              ],
              onChanged: (v) =>
                  setState(() => _filtro = _filtro.copiar(tema: () => v)),
            );
          },
        ),
      ],
    );
  }

  Widget _vazio(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        const Text('🏁', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          _filtro.soEstaSemana
              ? 'Ninguém pontuou nesta semana ainda.\nBora jogar?'
              : 'Ninguém pontuou com esses filtros ainda.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}

class _Linha extends StatelessWidget {
  const _Linha({required this.linha, required this.perfil});

  final LinhaPlacar linha;
  final Perfil perfil;

  static const _medalhas = {1: '🥇', 2: '🥈', 3: '🥉'};

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final medalha = linha.pontos > 0 ? _medalhas[linha.posicao] : null;
    final primeiro = linha.posicao == 1 && linha.pontos > 0;
    return Card(
      color: primeiro ? CoresMarca.amarelo.withValues(alpha: 0.25) : null,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                medalha ?? '${linha.posicao}º',
                textAlign: TextAlign.center,
                style: medalha != null
                    ? const TextStyle(fontSize: 26)
                    : texto.titleMedium,
              ),
            ),
            const SizedBox(width: 8),
            AvatarJogador(avatar: perfil.avatar, raio: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfil.nome,
                    style: texto.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    linha.desafios == 1
                        ? '1 desafio'
                        : '${linha.desafios} desafios',
                    style: texto.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${linha.pontos}',
              style: texto.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: CoresMarca.verde,
              ),
            ),
            const SizedBox(width: 4),
            Text('pts', style: texto.bodySmall),
          ],
        ),
      ),
    );
  }
}
