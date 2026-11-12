import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang_lite/services/session_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionPreferences', () {
    late SharedPreferences prefs;
    late SessionPreferences session;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      session = SessionPreferences(prefs);
    });

    test('default belum login dan tema gelap', () {
      expect(session.isLoggedIn, isFalse);
      expect(session.activeEmail, isNull);
      expect(session.themeMode, 'dark');
    });

    test('saveSession menyimpan status dan email', () async {
      await session.saveSession(email: 'wilda@example.com');

      expect(session.isLoggedIn, isTrue);
      expect(session.activeEmail, 'wilda@example.com');
      expect(prefs.getBool('is_logged_in'), isTrue);
      expect(prefs.getString('active_email'), 'wilda@example.com');
    });

    test('clearSession menghapus status dan email', () async {
      await session.saveSession(email: 'wilda@example.com');
      await session.clearSession();

      expect(session.isLoggedIn, isFalse);
      expect(session.activeEmail, isNull);
      expect(prefs.getBool('is_logged_in'), isFalse);
    });

    test('saveThemeMode menyimpan pilihan tema', () async {
      expect(session.themeMode, 'dark');

      await session.saveThemeMode('light');
      expect(session.themeMode, 'light');
      expect(prefs.getString('theme_mode'), 'light');
    });
  });
}
