import 'package:flutter/services.dart';

import 'banco.dart';

/// Sons do fim de jogo. Quem decide entre tocar, vibrar ou ficar quieto é o
/// lado Android (MainActivity), pelo modo do celular: Som toca; Vibrar ou
/// Silencioso só vibra; Não perturbe não faz nada.
enum Som { vitoria, recorde, conquista }

/// O som mais especial ganha: recorde, depois conquista, depois vitória.
Som somDoFim({required bool recorde, required bool conquista}) => recorde
    ? Som.recorde
    : conquista
    ? Som.conquista
    : Som.vitoria;

class Sons {
  const Sons._();

  static const _canal = MethodChannel('palavras_cruzadas/sons');

  /// Chave em Ajustes: '0' = desligado. Sem valor = ligado.
  static const chaveAjuste = 'sons';

  static Future<bool> ligados(Banco banco) async =>
      await banco.lerAjuste(chaveAjuste) != '0';

  static Future<void> ligar(Banco banco, {required bool ligado}) =>
      banco.gravarAjuste(chaveAjuste, ligado ? '1' : '0');

  static Future<void> tocar(Banco banco, Som som) async {
    if (!await ligados(banco)) return;
    try {
      await _canal.invokeMethod<String>('tocar', {'som': som.name});
    } on Object {
      // Sem o lado Android (testes) ou sem áudio: segue sem som.
    }
  }
}
