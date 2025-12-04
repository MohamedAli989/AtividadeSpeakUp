export 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart'
    show currentUserProvider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

/// Providers that belong to the `core` layer. Kept minimal — only the
/// `PersistenceService` provider is exposed here. Other feature-specific
/// providers should live under their respective feature folders.
final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});
