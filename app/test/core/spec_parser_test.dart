import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/core/utils/spec_parser.dart';

void main() {
  group('SpecParser', () {
    test('GPU mengekstrak VRAM, memori, dan brand', () {
      final specs = SpecParser.parse('gpu', 'ASUS RTX 4060 Dual 8GB GDDR6');
      expect(specs['VRAM'], '8GB');
      expect(specs['Memori'], 'GDDR6');
      expect(specs['Brand'], 'ASUS');
    });

    test('CPU mengekstrak socket, core, thread, boost', () {
      final specs = SpecParser.parse(
        'cpu',
        'AMD Ryzen 5 5600 6 Core 12 Thread 4.4GHz AM4',
      );
      expect(specs['Socket'], 'AM4');
      expect(specs['Core'], '6');
      expect(specs['Thread'], '12');
      expect(specs['Boost'], '4.4GHZ');
      expect(specs['Brand'], 'AMD');
    });

    test('motherboard mengekstrak socket dan chipset', () {
      final specs = SpecParser.parse(
        'motherboard',
        'MSI PRO B550M-VC WIFI AM4',
      );
      expect(specs['Socket'], 'AM4');
      expect(specs['Chipset'], 'B550');
    });

    test('RAM mengekstrak kapasitas, kecepatan, dan tipe', () {
      final specs = SpecParser.parse(
        'ram',
        'TeamGroup T-Force DDR4 16GB 3200MHz',
      );
      expect(specs['Kapasitas'], '16GB');
      expect(specs['Kecepatan'], '3200MHZ');
      expect(specs['Tipe'], 'DDR4');
    });

    test('storage mengekstrak kapasitas dan interface', () {
      final specs = SpecParser.parse(
        'storage',
        'ADATA Legend 710 1TB NVMe M.2',
      );
      expect(specs['Kapasitas'], '1TB');
      expect(specs['Interface'], 'NVME');
    });

    test('model tanpa pola dikenal tetap punya fallback', () {
      final specs = SpecParser.parse('gpu', 'Produk Misterius');
      expect(specs['Spesifikasi'], contains('Produk Misterius'));
    });
  });
}
