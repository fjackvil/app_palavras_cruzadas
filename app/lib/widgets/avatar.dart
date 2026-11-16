import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

/// Emojis que o jogador pode usar como avatar.
const avatares = [
  '🦁', '🐶', '🐱', '🐼', '🐸', '🦊', '🐵', '🐯', //
  '🦄', '🐙', '🐢', '🦉', '🚀', '⚽', '🌻', '🎸',
];

/// O avatar é guardado como texto: um emoji ou `foto:` seguido do caminho do arquivo.
/// A foto é copiada para a pasta do app e nunca sai do celular.
abstract final class Avatar {
  static const _prefixo = 'foto:';

  static bool ehFoto(String avatar) => avatar.startsWith(_prefixo);

  static String caminho(String avatar) => avatar.substring(_prefixo.length);

  /// Abre a galeria ou a câmera, guarda a foto (pequena) na pasta do app e
  /// devolve o avatar ("foto:..."), ou null se a pessoa desistiu.
  static Future<String?> escolherFoto(ImageSource origem) async {
    final escolhida = await ImagePicker().pickImage(
      source: origem,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (escolhida == null) return null;
    final pasta = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/avatares',
    );
    await pasta.create(recursive: true);
    final destino =
        '${pasta.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(escolhida.path).copy(destino);
    return '$_prefixo$destino';
  }

  /// Apaga o arquivo da foto, se o avatar for uma foto.
  static Future<void> apagarFoto(String avatar) async {
    if (!ehFoto(avatar)) return;
    final arquivo = File(caminho(avatar));
    if (await arquivo.exists()) await arquivo.delete();
  }
}

/// Mostra o avatar num círculo: a foto ou o emoji.
class AvatarJogador extends StatelessWidget {
  const AvatarJogador({
    super.key,
    required this.avatar,
    this.raio = 28,
    this.fundo,
  });

  final String avatar;
  final double raio;
  final Color? fundo;

  @override
  Widget build(BuildContext context) {
    if (Avatar.ehFoto(avatar)) {
      return CircleAvatar(
        radius: raio,
        backgroundColor: fundo,
        backgroundImage: FileImage(File(Avatar.caminho(avatar))),
      );
    }
    return CircleAvatar(
      radius: raio,
      backgroundColor: fundo ?? Colors.transparent,
      child: Text(avatar, style: TextStyle(fontSize: raio * 1.05)),
    );
  }
}

/// Escolha do avatar: foto (galeria ou câmera) ou um dos emojis.
class EscolhaAvatar extends StatelessWidget {
  const EscolhaAvatar({
    super.key,
    required this.atual,
    required this.aoEscolher,
  });

  final String atual;
  final ValueChanged<String> aoEscolher;

  Future<void> _foto(BuildContext context, ImageSource origem) async {
    try {
      final avatar = await Avatar.escolherFoto(origem);
      if (avatar != null) aoEscolher(avatar);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não deu para abrir a foto.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AvatarJogador(avatar: atual, raio: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Foto da galeria'),
                    onPressed: () => _foto(context, ImageSource.gallery),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Tirar foto'),
                    onPressed: () => _foto(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Ou escolha um desenho:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in avatares)
              ChoiceChip(
                label: Text(a, style: const TextStyle(fontSize: 28)),
                selected: a == atual,
                showCheckmark: false,
                onSelected: (_) => aoEscolher(a),
              ),
          ],
        ),
      ],
    );
  }
}
