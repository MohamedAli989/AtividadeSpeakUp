// lib/features/4_profile/data/dtos/user_dto.dart
import 'dart:convert';

class UserDTO {
  final String? name;
  final String? email;
  final String? description;
  final String? photoUrl;
  final bool loggedIn;

  const UserDTO({
    this.name,
    this.email,
    this.description,
    this.photoUrl,
    this.loggedIn = false,
  });

  UserDTO copyWith({
    String? name,
    String? email,
    String? description,
    String? photoUrl,
    bool? loggedIn,
  }) {
    return UserDTO(
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      loggedIn: loggedIn ?? this.loggedIn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'description': description,
      'photoUrl': photoUrl,
      'loggedIn': loggedIn,
    };
  }

  factory UserDTO.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserDTO();

    return UserDTO(
      name: map['name'] as String?,
      email: map['email'] as String?,
      description: map['description'] as String?,
      photoUrl: map['photoUrl'] as String?,
      loggedIn: map['loggedIn'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDTO.fromJson(String source) =>
      UserDTO.fromMap(json.decode(source) as Map<String, dynamic>?);

  @override
  String toString() =>
      'UserDTO(name: $name, email: $email, description: $description, photoUrl: $photoUrl, loggedIn: $loggedIn)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDTO &&
        other.name == name &&
        other.email == email &&
        other.description == description &&
        other.photoUrl == photoUrl &&
        other.loggedIn == loggedIn;
  }

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      description.hashCode ^
      photoUrl.hashCode ^
      loggedIn.hashCode;
}
