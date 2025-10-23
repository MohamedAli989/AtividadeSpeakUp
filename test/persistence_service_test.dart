import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistenceService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('user data set/get/remove', () async {
      final svc = PersistenceService();
      await svc.setUserData(name: 'Alice', email: 'alice@example.com');
      expect(await svc.getUserName(), 'Alice');
      expect(await svc.getUserEmail(), 'alice@example.com');
      await svc.removeUserData();
      expect(await svc.getUserName(), isNull);
      expect(await svc.getUserEmail(), isNull);
    });

    test('marketing consent set/get/remove', () async {
      final svc = PersistenceService();
      await svc.setMarketingConsent(true);
      expect(await svc.getMarketingConsent(), isTrue);
      await svc.removeMarketingConsent();
      expect(await svc.getMarketingConsent(), isFalse);
    });

    test('login state set/get/remove', () async {
      final svc = PersistenceService();
      await svc.setLoggedIn(true);
      expect(await svc.getLoggedIn(), isTrue);
      await svc.removeLoggedIn();
      expect(await svc.getLoggedIn(), isFalse);
    });
  });
}
