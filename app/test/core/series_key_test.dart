import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/core/utils/series_key.dart';

void main() {
  group('SeriesKey.of', () {
    test('GPU memisahkan RTX 4060 dan RTX 4060 Ti', () {
      expect(
        SeriesKey.of('gpu', 'MSI GeForce RTX 4060 8GB GDDR6 Ventus'),
        'RTX 4060',
      );
      expect(
        SeriesKey.of('gpu', 'ASUS GeForce RTX 4060 Ti 8GB GDDR6 Dual'),
        'RTX 4060 TI',
      );
      expect(
        SeriesKey.of('gpu', 'ASRock Radeon RX 9060 XT 16GB GDDR6'),
        'RX 9060 XT',
      );
    });

    test('CPU mengenali Ryzen, Core i, dan Core Ultra', () {
      expect(
        SeriesKey.of('cpu', 'AMD Ryzen 5 5600 3.5GHz 6 Core AM4'),
        'RYZEN 5 5600',
      );
      expect(
        SeriesKey.of('cpu', 'Intel Core i5-12400F 2.5GHz 6 Core'),
        'CORE I5-12400F',
      );
      expect(
        SeriesKey.of('cpu', 'Intel Core Ultra 7 155H 3.8GHz'),
        'CORE ULTRA 7 155H',
      );
    });

    test('motherboard memakai chipset tanpa suffix form factor', () {
      expect(SeriesKey.of('motherboard', 'MSI PRO B550M-VC WIFI AM4'), 'B550');
      expect(SeriesKey.of('motherboard', 'ASRock A620AI WIFI AM5'), 'A620A');
    });

    test('RAM memakai tipe, kapasitas, dan kecepatan', () {
      expect(
        SeriesKey.of('ram', 'ADATA XPG DDR4 PC25600 3200MHz 16GB (2x8GB)'),
        'DDR4 16GB 3200MHZ',
      );
    });

    test('storage memakai interface dan kapasitas', () {
      expect(
        SeriesKey.of('storage', 'ADATA Legend 710 1TB M.2 NVMe'),
        'NVME 1TB',
      );
      expect(
        SeriesKey.of('storage', 'Seagate Barracuda 1TB HDD SATA'),
        'SATA 1TB',
      );
    });

    test('model tanpa pola dikenal memakai nama apa adanya', () {
      expect(SeriesKey.of('gpu', 'Produk Misterius'), 'PRODUK MISTERIUS');
    });
  });

  group('SeriesKey.display', () {
    test('merapikan akronim GPU dan nama CPU', () {
      expect(SeriesKey.display('gpu', 'RTX 4060 TI'), 'RTX 4060 Ti');
      expect(SeriesKey.display('cpu', 'RYZEN 5 5600'), 'Ryzen 5 5600');
      expect(SeriesKey.display('cpu', 'CORE I5-12400F'), 'Core i5-12400F');
    });

    test('merapikan satuan RAM dan interface storage', () {
      expect(
        SeriesKey.display('ram', 'DDR4 16GB 3200MHZ'),
        'DDR4 16GB 3200MHz',
      );
      expect(SeriesKey.display('storage', 'NVME 1TB'), 'NVMe 1TB');
    });
  });
}
