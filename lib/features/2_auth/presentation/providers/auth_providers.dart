import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/2_auth/data/repositories/auth_repository_impl.dart';
import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';
import 'package:pprincipal/features/2_auth/domain/usecases/login_usecase.dart';
import 'package:pprincipal/features/2_auth/domain/usecases/pular_login_usecase.dart';
import 'package:pprincipal/features/2_auth/domain/usecases/aceitar_termos_usecase.dart';
import 'package:pprincipal/features/2_auth/domain/usecases/verificar_status_app_usecase.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final pularLoginUseCaseProvider = Provider<PularLoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return PularLoginUseCase(repo);
});

final aceitarTermosUseCaseProvider = Provider<AceitarTermosUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AceitarTermosUseCase(repo);
});

final verificarStatusAppUseCaseProvider = FutureProvider<String>((ref) async {
  final usecase = VerificarStatusAppUseCase();
  return await usecase.call();
});
