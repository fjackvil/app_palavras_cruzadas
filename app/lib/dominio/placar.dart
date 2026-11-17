import 'nivel.dart';

/// O que o placar precisa saber de um desafio concluído.
class RegistroPlacar {
  const RegistroPlacar({
    required this.perfilId,
    required this.modo,
    required this.nivel,
    required this.temas,
    required this.pontos,
    required this.quando,
    this.segundos = 0,
    this.partidaId = 0,
    this.dicas = 0,
  });

  /// Lê o id do desafio: "cruzadas:medio:animais+frutas:123",
  /// "caca:leve:animais:9" ou "cruzadas:diario:leve:2026-11-16".
  /// Desafio do dia não tem temas no id (fica com lista vazia).
  factory RegistroPlacar.doDesafio({
    required int perfilId,
    required String modo,
    required String desafioId,
    required int pontos,
    required DateTime quando,
    int segundos = 0,
    int partidaId = 0,
    int dicas = 0,
  }) {
    final partes = desafioId.split(':');
    final diario = partes.length >= 4 && partes[1] == 'diario';
    final nivel = Nivel.porNome(
      diario ? partes[2] : (partes.length > 1 ? partes[1] : ''),
    );
    final temas = !diario && partes.length > 2
        ? partes[2].split('+')
        : const <String>[];
    return RegistroPlacar(
      perfilId: perfilId,
      modo: modo,
      nivel: nivel,
      temas: temas,
      pontos: pontos,
      quando: quando,
      segundos: segundos,
      partidaId: partidaId,
      dicas: dicas,
    );
  }

  final int perfilId;
  final String modo;
  final Nivel nivel;
  final List<String> temas;
  final int pontos;
  final DateTime quando;

  /// Tempo gasto no desafio.
  final int segundos;
  final int partidaId;

  /// Dicas usadas no desafio.
  final int dicas;
}

/// Filtros do placar. null = todos.
class FiltroPlacar {
  const FiltroPlacar({
    this.soEstaSemana = true,
    this.modo,
    this.nivel,
    this.tema,
  });

  final bool soEstaSemana;
  final String? modo;
  final Nivel? nivel;

  /// Só desafios montados com esse tema sozinho.
  final String? tema;

  FiltroPlacar copiar({
    bool? soEstaSemana,
    String? Function()? modo,
    Nivel? Function()? nivel,
    String? Function()? tema,
  }) => FiltroPlacar(
    soEstaSemana: soEstaSemana ?? this.soEstaSemana,
    modo: modo != null ? modo() : this.modo,
    nivel: nivel != null ? nivel() : this.nivel,
    tema: tema != null ? tema() : this.tema,
  );
}

/// Uma linha do placar.
class LinhaPlacar {
  const LinhaPlacar({
    required this.perfilId,
    required this.pontos,
    required this.desafios,
    required this.posicao,
  });

  final int perfilId;
  final int pontos;
  final int desafios;

  /// 1, 2, 3... Empate em pontos divide a mesma posição.
  final int posicao;
}

abstract final class Placar {
  /// Segunda-feira 00:00 da semana de [agora].
  static DateTime inicioDaSemana(DateTime agora) {
    final dia = DateTime(agora.year, agora.month, agora.day);
    return dia.subtract(Duration(days: dia.weekday - DateTime.monday));
  }

  static bool passa(RegistroPlacar r, FiltroPlacar f, DateTime agora) {
    if (f.soEstaSemana && r.quando.isBefore(inicioDaSemana(agora))) {
      return false;
    }
    if (f.modo != null && r.modo != f.modo) return false;
    if (f.nivel != null && r.nivel != f.nivel) return false;
    if (f.tema != null && !(r.temas.length == 1 && r.temas.first == f.tema)) {
      return false;
    }
    return true;
  }

  /// Ranking de todos os [perfis], inclusive quem ainda não pontuou.
  /// Ordem: mais pontos, depois mais desafios, depois o id do perfil.
  static List<LinhaPlacar> calcular({
    required List<int> perfis,
    required List<RegistroPlacar> registros,
    required FiltroPlacar filtro,
    required DateTime agora,
  }) {
    final pontos = {for (final p in perfis) p: 0};
    final desafios = {for (final p in perfis) p: 0};
    for (final r in registros) {
      if (!pontos.containsKey(r.perfilId) || !passa(r, filtro, agora)) {
        continue;
      }
      pontos[r.perfilId] = pontos[r.perfilId]! + r.pontos;
      desafios[r.perfilId] = desafios[r.perfilId]! + 1;
    }
    final ordem = [...perfis]
      ..sort((a, b) {
        final porPontos = pontos[b]!.compareTo(pontos[a]!);
        if (porPontos != 0) return porPontos;
        final porDesafios = desafios[b]!.compareTo(desafios[a]!);
        return porDesafios != 0 ? porDesafios : a.compareTo(b);
      });
    final linhas = <LinhaPlacar>[];
    for (var i = 0; i < ordem.length; i++) {
      final id = ordem[i];
      final empatado = i > 0 && pontos[ordem[i - 1]] == pontos[id];
      linhas.add(
        LinhaPlacar(
          perfilId: id,
          pontos: pontos[id]!,
          desafios: desafios[id]!,
          posicao: empatado ? linhas.last.posicao : i + 1,
        ),
      );
    }
    return linhas;
  }
}
