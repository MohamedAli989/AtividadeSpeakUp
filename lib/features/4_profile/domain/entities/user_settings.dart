// lib/features/4_profile/domain/entities/user_settings.dart
// Entidade que representa as preferências/configurações do utilizador.

class UserSettings {
  /// Identificador do utilizador ao qual estas configurações pertencem.
  final String userId;

  /// Meta diária em minutos (ex.: 10).
  final int metaDiariaMinutos;

  /// Idioma ativo (ex.: "en-US").
  final String idiomaAtivoId;

  /// Velocidade de reprodução para exemplos/áudio (ex.: 1.0).
  final double velocidadeReproducao;

  /// Hora do lembrete no formato HH:mm (ex.: "18:30") ou `null` se desativado.
  final String? horaLembrete;

  const UserSettings({
    required this.userId,
    required this.metaDiariaMinutos,
    required this.idiomaAtivoId,
    required this.velocidadeReproducao,
    this.horaLembrete,
  });

  /// Cria uma instância a partir de JSON.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['userId'] as String,
      metaDiariaMinutos: (json['metaDiariaMinutos'] as num).toInt(),
      idiomaAtivoId: json['idiomaAtivoId'] as String,
      velocidadeReproducao: (json['velocidadeReproducao'] as num).toDouble(),
      horaLembrete: json['horaLembrete'] as String?,
    );
  }

  /// Converte a entidade para JSON.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'metaDiariaMinutos': metaDiariaMinutos,
      'idiomaAtivoId': idiomaAtivoId,
      'velocidadeReproducao': velocidadeReproducao,
      'horaLembrete': horaLembrete,
    };
  }

  /// Retorna uma cópia da entidade com campos substituídos conforme parâmetros.
  UserSettings copyWith({
    String? userId,
    int? metaDiariaMinutos,
    String? idiomaAtivoId,
    double? velocidadeReproducao,
    String? horaLembrete,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      metaDiariaMinutos: metaDiariaMinutos ?? this.metaDiariaMinutos,
      idiomaAtivoId: idiomaAtivoId ?? this.idiomaAtivoId,
      velocidadeReproducao: velocidadeReproducao ?? this.velocidadeReproducao,
      horaLembrete: horaLembrete ?? this.horaLembrete,
    );
  }

  /// Factory que cria as configurações padrão para um dado utilizador.
  factory UserSettings.defaultSettings(String userId) {
    return UserSettings(
      userId: userId,
      metaDiariaMinutos: 10,
      idiomaAtivoId: 'en-US',
      velocidadeReproducao: 1.0,
      horaLembrete: null,
    );
  }
}
