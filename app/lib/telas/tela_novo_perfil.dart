import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../dominio/nivel.dart';
import '../widgets/avatar.dart';

/// Cadastro de um jogador: nome, idade e avatar. Fica só no celular.
class TelaNovoPerfil extends StatefulWidget {
  const TelaNovoPerfil({super.key});

  @override
  State<TelaNovoPerfil> createState() => _TelaNovoPerfilState();
}

class _TelaNovoPerfilState extends State<TelaNovoPerfil> {
  final _nome = TextEditingController();
  int _idade = 8;
  String _avatar = avatares.first;
  bool _salvando = false;

  Nivel get _nivelSugerido => Nivel.sugeridoParaIdade(_idade);

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return;
    setState(() => _salvando = true);
    final banco = Servicos.of(context).banco;
    await banco.criarPerfil(
      nome: nome,
      anoNascimento: DateTime.now().year - _idade,
      avatar: _avatar,
      nivel: _nivelSugerido.name,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Novo jogador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nome,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome ou apelido',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Idade: $_idade anos', style: texto.titleMedium),
          Slider(
            value: _idade.toDouble(),
            min: 4,
            max: 90,
            divisions: 86,
            label: '$_idade',
            onChanged: (v) => setState(() => _idade = v.round()),
          ),
          Text('Nível sugerido: ${_nivelSugerido.nome}. Dá para mudar depois.'),
          const SizedBox(height: 16),
          Text('Foto ou avatar', style: texto.titleMedium),
          const SizedBox(height: 8),
          EscolhaAvatar(
            atual: _avatar,
            aoEscolher: (a) => setState(() => _avatar = a),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _nome.text.trim().isEmpty || _salvando ? null : _salvar,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
