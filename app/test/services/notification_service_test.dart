import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Fake & Contract', () {
    late FakeNotificationService service;

    setUp(() {
      service = FakeNotificationService();
    });

    test('showImmediate merekam notifikasi langsung', () async {
      await service.showImmediate(
        id: 1,
        title: 'Wishlist Ditambahkan 🎯',
        body: 'RTX 4060 berhasil disimpan.',
      );

      expect(service.immediateHistory, hasLength(1));
      expect(service.immediateHistory.first['id'], 1);
      expect(service.immediateHistory.first['title'], 'Wishlist Ditambahkan 🎯');
    });

    test('scheduleDailyReminder merekam pengingat terjadwal', () async {
      await service.scheduleDailyReminder(
        id: LocalNotificationService.dailyReminderId,
        title: 'Waktunya Cek Harga Komponen PC! 💻',
        body: 'Cek kembali harga komponen impianmu.',
        hour: 19,
        minute: 0,
      );

      expect(service.scheduledReminder, isNotNull);
      expect(service.scheduledReminder!['id'], 1001);
      expect(service.scheduledReminder!['hour'], 19);
      expect(service.scheduledReminder!['minute'], 0);
    });

    test('cancelDailyReminder membatalkan jadwal pengingat', () async {
      await service.scheduleDailyReminder(
        id: LocalNotificationService.dailyReminderId,
        title: 'Pengingat',
        body: 'Isi pengingat',
        hour: 19,
        minute: 0,
      );
      expect(service.scheduledReminder, isNotNull);

      await service.cancelDailyReminder();
      expect(service.scheduledReminder, isNull);
    });

    test('cancel menghapus notifikasi dengan id yang sesuai', () async {
      await service.showImmediate(id: 1, title: 'Notif 1', body: 'Body 1');
      await service.showImmediate(id: 2, title: 'Notif 2', body: 'Body 2');
      expect(service.immediateHistory, hasLength(2));

      await service.cancel(1);
      expect(service.immediateHistory, hasLength(1));
      expect(service.immediateHistory.single['id'], 2);
    });
  });
}
