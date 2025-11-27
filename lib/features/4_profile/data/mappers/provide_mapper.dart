// lib/features/4_profile/data/mappers/provide_mapper.dart
import 'package:pprincipal/features/4_profile/data/dtos/user_dto.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';

class ProvideMapper {
  static UserDTO toDto(UserProfile u) {
    return UserDTO(
      name: u.name,
      email: u.email,
      description: u.description,
      loggedIn: u.loggedIn,
    );
  }

  static UserProfile fromDto(UserDTO dto) {
    return UserProfile(
      name: dto.name,
      email: dto.email,
      description: dto.description,
      loggedIn: dto.loggedIn,
    );
  }
}
