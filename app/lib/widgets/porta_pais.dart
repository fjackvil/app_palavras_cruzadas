import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../dominio/porta_pais.dart';

/// Pede a resposta de uma conta antes da compra. Devolve true só se a
/// resposta estiver certa.
Future<bool> confirmarAdulto(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => DialogoPortaPais(pergunta: PerguntaPais.sortear()),
  );
  return ok ?? false;
}

class DialogoPortaPais extends StatefulWidget {
  const DialogoPortaPais({super.key, required this.pergunta});

  final PerguntaPais pergunta;

  @override
  State<DialogoPortaPais> createState() => _DialogoPortaPaisState();
}

class _DialogoPortaPaisState extends State<DialogoPortaPais> {
  final _campo = TextEditingController();
  final _foco = FocusNode();
  bool _errou = false;

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _conferir() {
    if (widget.pergunta.confere(_campo.text)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errou = true);
      _campo.clear();
      _foco.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pergunta para um adulto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Para continuar a compra, responda:'),
          const SizedBox(height: 12),
          Text(
            widget.pergunta.texto,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          TextField(
            controller: _campo,
            focusNode: _foco,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            decoration: InputDecoration(
              hintText: 'Resposta',
              counterText: '',
              errorText: _errou ? 'Resposta errada. Tente de novo.' : null,
            ),
            onSubmitted: (_) => _conferir(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _conferir, child: const Text('Continuar')),
      ],
    );
  }
}
