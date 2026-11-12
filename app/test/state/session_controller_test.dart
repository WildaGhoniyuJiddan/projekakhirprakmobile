import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang_lite/services/auth_service.dart';
import 'package:worthbang_lite/services/session_preferences.dart';
import 'package:worthbang_lite/state/session_controller.dart';

import '../support/hive_test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveTestEnvironment env;
  late SessionPreferences prefs;
  late SessionController controller;

  setUpAll(() async {
    env = await HiveTestEnvironment.create();
  });

  tearDownAll(() async {
    await env.dispose();
  });

  setUp(() async {
    await env.accountsBox.clear();
    SharedPreferences.setMockInitialValues({});
    prefs = SessionPreferences(await SharedPreferences.getInstance());
    controller = SessionController(AuthService(env.accountsBox, prefs));
    await controller.restore();
  });

  group('SessionController', () {
    test('register mengisi user dan memberi notifikasi', () async {
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      expect(controller.isLoggedIn, isTrue);
      expect(controller.user!.name, 'Wilda');
      expect(notifications, 1);
    });

    test('login mengisi user dan sesi tersimpan', () async {
      await controller.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );
      await controller.logout();

      expect(controller.isLoggedIn, isFalse);

      await controller.login(
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      expect(controller.isLoggedIn, isTrue);
      expect(prefs.isLoggedIn, isTrue);
    });

    test('restore memulihkan sesi setelah aplikasi dibuka ulang', () async {
      await controller.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      final restarted = SessionController(AuthService(env.accountsBox, prefs));
      expect(restarted.isLoggedIn, isFalse);

      await restarted.restore();

      expect(restarted.isRestoring, isFalse);
      expect(restarted.isLoggedIn, isTrue);
      expect(restarted.user!.email, 'wilda@example.com');
    });

    test('logout menghapus user dan sesi', () async {
      await controller.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      await controller.logout();

      expect(controller.isLoggedIn, isFalse);
      expect(controller.user, isNull);
      expect(prefs.isLoggedIn, isFalse);
    });
  });
}
