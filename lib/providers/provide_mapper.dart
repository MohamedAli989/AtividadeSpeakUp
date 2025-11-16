// lib/providers/provide_mapper.dart

import 'package:pprincipal/providers/user_dto.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';

/// Mapper entre o domínio `User` e o `UserDTO` serializável.
/// ProvideMapper centraliza a lógica de conversão para que a persistência
/// trabalhe com DTOs.
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
