// lib/providers/provide_mapper.dart

import 'user_dto.dart';
import 'user_provider.dart';

/// Mapper between domain `User` and serializable `UserDTO`.
/// ProvideMapper centralizes conversion logic so persistence can work with DTOs.
class ProvideMapper {
  static UserDTO toDto(User u) {
    return UserDTO(
      name: u.name,
      email: u.email,
      description: u.description,
      loggedIn: u.loggedIn,
    );
  }

  static User fromDto(UserDTO dto) {
    return User(
      name: dto.name,
      email: dto.email,
      description: dto.description,
      loggedIn: dto.loggedIn,
    );
  }
}
