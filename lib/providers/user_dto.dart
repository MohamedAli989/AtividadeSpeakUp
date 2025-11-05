// lib/providers/user_dto.dart
import 'dart:convert';

/// Data Transfer Object para o registro de usuário persistido pelo app.
///
/// Este DTO é intencionalmente leve e serializável para Map/JSON.
class UserDTO {
  final String? name;
  final String? email;
  final String? description;
  final bool loggedIn;

  const UserDTO({
    this.name,
    this.email,
    this.description,
    this.loggedIn = false,
  });

  UserDTO copyWith({
    String? name,
    String? email,
    String? description,
    bool? loggedIn,
  }) {
    return UserDTO(
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      loggedIn: loggedIn ?? this.loggedIn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'description': description,
      'loggedIn': loggedIn,
    };
  }

  factory UserDTO.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserDTO();

    return UserDTO(
      name: map['name'] as String?,
      email: map['email'] as String?,
      description: map['description'] as String?,
      loggedIn: map['loggedIn'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDTO.fromJson(String source) =>
      UserDTO.fromMap(json.decode(source) as Map<String, dynamic>?);

  @override
  String toString() =>
      'UserDTO(name: $name, email: $email, description: $description, loggedIn: $loggedIn)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDTO &&
        other.name == name &&
        other.email == email &&
        other.description == description &&
        other.loggedIn == loggedIn;
  }

  @override
  int get hashCode =>
      name.hashCode ^ email.hashCode ^ description.hashCode ^ loggedIn.hashCode;
}
