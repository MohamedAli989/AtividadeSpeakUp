// lib/features/4_profile/domain/repositories/i_profile_repository.dart
import 'dart:io';
import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_settings.dart';

abstract class IProfileRepository {
  Future<UserProfile?> carregarPerfilUsuario(String userId);
  Future<void> salvarPerfilUsuario(String userId, UserProfile profile);
  Future<UserSettings> carregarConfiguracoes(String userId);
  Future<void> salvarConfiguracoes(UserSettings configuracoes);
  Future<String?> uploadAvatar(File imageFile, String userId);
}
