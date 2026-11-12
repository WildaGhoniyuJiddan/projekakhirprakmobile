import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang_lite/services/auth_service.dart';
import 'package:worthbang_lite/services/session_preferences.dart';

import '../support/hive_test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveTestEnvironment env;
  late SessionPreferences prefs;
  late AuthService auth;

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
    auth = AuthService(env.accountsBox, prefs);
  });

  group('AuthService', () {
    test('register menyimpan akun, hash, salt, dan sesi', () async {
      final user = await auth.register(
        name: '  Wilda  ',
        email: 'Wilda@Example.com',
        password: 'rahasia123',
      );

      expect(user.name, 'Wilda');
      expect(user.email, 'wilda@example.com');
      expect(user.id, 1);
      expect(prefs.isLoggedIn, isTrue);
      expect(prefs.activeEmail, 'wilda@example.com');

      final raw = env.accountsBox.get('wilda@example.com') as Map;
      expect(raw['password_hash'], isNotEmpty);
      expect(raw['password_hash'], isNot(contains('rahasia123')));
      expect(raw['salt'], isNotEmpty);
    });

    test('register menolak email duplikat', () async {
      await auth.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      await expectLater(
        auth.register(
          name: 'Wilda Lain',
          email: 'wilda@example.com',
          password: 'rahasia456',
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('sudah terdaftar'),
          ),
        ),
      );
    });

    test('register menolak email dan kata sandi tidak valid', () async {
      await expectLater(
        auth.register(
          name: 'Wilda',
          email: 'bukan-email',
          password: 'rahasia123',
        ),
        throwsA(isA<AuthException>()),
      );

      await expectLater(
        auth.register(
          name: 'Wilda',
          email: 'wilda@example.com',
          password: 'pendek',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('login berhasil dan menyimpan sesi', () async {
      await auth.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );
      await prefs.clearSession();

      final user = await auth.login(
        email: 'WILDA@example.com',
        password: 'rahasia123',
      );

      expect(user.email, 'wilda@example.com');
      expect(prefs.isLoggedIn, isTrue);
      expect(prefs.activeEmail, 'wilda@example.com');
    });

    test('login menolak kata sandi salah dan email tak dikenal', () async {
      await auth.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      await expectLater(
        auth.login(email: 'wilda@example.com', password: 'salah-sekali'),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        auth.login(email: 'tidak@example.com', password: 'rahasia123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('restoreSession memulihkan akun setelah login', () async {
      await auth.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );

      final freshAuth = AuthService(env.accountsBox, prefs);
      final restored = await freshAuth.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.email, 'wilda@example.com');
      expect(restored.name, 'Wilda');
    });

    test('logout menghapus sesi dan restore mengembalikan null', () async {
      await auth.register(
        name: 'Wilda',
        email: 'wilda@example.com',
        password: 'rahasia123',
      );
      await auth.logout();

      expect(prefs.isLoggedIn, isFalse);
      expect(await auth.restoreSession(), isNull);
    });

    test('restoreSession membersihkan sesi jika akun hilang', () async {
      await prefs.saveSession(email: 'hantu@example.com');

      expect(await auth.restoreSession(), isNull);
      expect(prefs.isLoggedIn, isFalse);
      expect(prefs.activeEmail, isNull);
    });
  });
}
