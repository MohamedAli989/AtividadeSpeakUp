import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';
import 'package:pprincipal/features/4_profile/domain/repositories/i_profile_repository.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_settings.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final PersistenceService _persistenceService;
  ProfileRepositoryImpl(this._persistenceService);

  @override
  Future<UserProfile?> carregarPerfilUsuario(String userId) async {
    // O PersistenceService atua como a nossa Fonte de Dados Local (DataSource)
    final nome = await _persistenceService.getUserName();
    final email = await _persistenceService.getUserEmail();
    if (nome == null || email == null) return null;
    return UserProfile(name: nome, email: email);
  }

  @override
  Future<void> salvarPerfilUsuario(String userId, UserProfile profile) async {
    if (profile.name == null || profile.email == null) return;
    await _persistenceService.setUserData(
      name: profile.name!,
      email: profile.email!,
    );
  }

  @override
  Future<UserSettings> carregarConfiguracoes(String userId) async {
    // Tenta ler valores atômicos do PersistenceService
    final meta = await _persistenceService.getMetaDiaria(userId);
    final idioma = await _persistenceService.getIdiomaAtivo(userId);
    final velocidade = await _persistenceService.getVelocidadeReproducao(
      userId,
    );
    final hora = await _persistenceService.getHoraLembrete(userId);

    // Se nenhum valor foi persistido, retorna as configurações padrão
    if (meta == null && idioma == null && velocidade == null && hora == null) {
      return UserSettings.defaultSettings(userId);
    }

    return UserSettings(
      userId: userId,
      metaDiariaMinutos: meta ?? 10,
      idiomaAtivoId: idioma ?? 'en-US',
      velocidadeReproducao: velocidade ?? 1.0,
      horaLembrete: hora,
    );
  }

  @override
  Future<void> salvarConfiguracoes(UserSettings configuracoes) async {
    await _persistenceService.setMetaDiaria(
      configuracoes.userId,
      configuracoes.metaDiariaMinutos,
    );
    await _persistenceService.setIdiomaAtivo(
      configuracoes.userId,
      configuracoes.idiomaAtivoId,
    );
    await _persistenceService.setVelocidadeReproducao(
      configuracoes.userId,
      configuracoes.velocidadeReproducao,
    );
    await _persistenceService.setHoraLembrete(
      configuracoes.userId,
      configuracoes.horaLembrete,
    );
  }
}
