import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/user_account.dart';

void main() {
  group('UserAccount', () {
    test('generative constructor menormalkan nama dan email', () {
      final user = UserAccount(
        id: 1,
        name: '  Wilda  ',
        email: '  WILDA@Example.com ',
      );
      expect(user.name, 'Wilda');
      expect(user.email, 'wilda@example.com');
    });

    test('redirecting constructor .empty memberi akun tamu', () {
      final guest = UserAccount.empty();
      expect(guest.id, 0);
      expect(guest.name, 'Tamu');
      expect(guest.email, 'tamu@worthbang.local');
      expect(guest.avatarUrl, contains('tamu%40worthbang.local'));
    });

    test('fromMap/toMap round-trip', () {
      final user = UserAccount.fromMap({
        'id': 7,
        'name': 'Dan',
        'email': 'dan@example.com',
        'avatar_url': 'https://example.com/dan.png',
      });
      expect(user.id, 7);
      expect(user.name, 'Dan');
      expect(user.avatarUrl, 'https://example.com/dan.png');
      expect(user.toMap()['email'], 'dan@example.com');
    });

    test('setter memvalidasi nama dan email', () {
      final user = UserAccount.empty();
      user.name = 'Admin';
      user.email = 'admin@example.com';
      expect(user.name, 'Admin');
      expect(user.email, 'admin@example.com');
      expect(() => user.name = '   ', throwsArgumentError);
      expect(() => user.email = 'bukan-email', throwsArgumentError);
    });
  });
}
