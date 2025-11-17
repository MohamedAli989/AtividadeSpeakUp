import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

class AcceptedTermsNotifier extends StateNotifier<bool> {
  final PersistenceService _svc;

  AcceptedTermsNotifier(this._svc) : super(false) {
    _load();
  }

  Future<void> _load() async {
    final val = await _svc.getAcceptedTerms();
    state = val;
  }

  Future<void> setAccepted(bool value) async {
    await _svc.setAcceptedTerms(value);
    state = value;
  }
}

final acceptedTermsProvider =
    StateNotifierProvider<AcceptedTermsNotifier, bool>((ref) {
      return AcceptedTermsNotifier(PersistenceService());
    });
