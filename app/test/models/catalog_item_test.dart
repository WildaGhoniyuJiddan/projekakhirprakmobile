import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/catalog_item.dart';

void main() {
  group('CatalogItem', () {
    test('fromJson membuat subclass sesuai seksi', () {
      expect(
        CatalogItem.fromJson('cpu', {
          'model': 'Ryzen 5 5600',
          'price': 1800000,
        }),
        isA<CpuItem>(),
      );
      expect(
        CatalogItem.fromJson('gpu', {'model': 'RTX 4060', 'price': 4500000}),
        isA<GpuItem>(),
      );
      expect(
        CatalogItem.fromJson('motherboard', {
          'model': 'MSI B550M',
          'price': 1200000,
        }),
        isA<MotherboardItem>(),
      );
      expect(
        CatalogItem.fromJson('ram', {'model': 'DDR4 16GB', 'price': 700000}),
        isA<RamItem>(),
      );
      expect(
        CatalogItem.fromJson('storage', {'model': 'NVMe 1TB', 'price': 900000}),
        isA<StorageItem>(),
      );
    });

    test('fromJson menolak item tanpa harga valid', () {
      expect(
        () => CatalogItem.fromJson('gpu', {'model': '', 'price': 0}),
        throwsFormatException,
      );
      expect(
        () => CatalogItem.fromJson('unknown', {'model': 'X', 'price': 1000}),
        throwsArgumentError,
      );
    });

    test('CPU dan GPU memakai harganya sendiri', () {
      const cpu = CpuItem(model: 'Ryzen 5 5600', price: 1800000);
      const gpu = GpuItem(model: 'RTX 4060', price: 4500000);
      expect(cpu.referencePrice(const []), 1800000);
      expect(gpu.referencePrice(const []), 4500000);
      expect(cpu.sectionLabel, 'CPU');
      expect(gpu.sectionLabel, 'GPU');
    });

    test('RAM memakai median harga dengan kapasitas sama', () {
      const target = RamItem(model: 'DDR4 16GB 3200MHz', price: 700000);
      const pool = [
        RamItem(model: 'DDR4 16GB 3200MHz', price: 600000),
        RamItem(model: 'DDR4 16GB 3200MHz', price: 900000),
        RamItem(model: 'DDR4 16GB 3200MHz', price: 750000),
        RamItem(model: 'DDR4 32GB 3600MHz', price: 1500000),
      ];
      expect(target.referencePrice(pool), 750000);
    });

    test('storage memakai median harga dengan kapasitas sama', () {
      const target = StorageItem(model: 'NVMe 1TB', price: 900000);
      const pool = [
        StorageItem(model: 'NVMe 1TB', price: 800000),
        StorageItem(model: 'NVMe 1TB', price: 1000000),
        StorageItem(model: 'NVMe 1TB', price: 1200000),
        StorageItem(model: 'SATA 512GB', price: 500000),
      ];
      expect(target.referencePrice(pool), 1000000);
    });

    test('motherboard memakai median chipset yang sama', () {
      const target = MotherboardItem(model: 'MSI B550M', price: 1200000);
      const pool = [
        MotherboardItem(model: 'ASUS B550', price: 1000000),
        MotherboardItem(model: 'Gigabyte B550', price: 1400000),
        MotherboardItem(model: 'MSI B550', price: 1200000),
        MotherboardItem(model: 'ASRock B650', price: 2000000),
      ];
      expect(target.referencePrice(pool), 1200000);
    });

    test('displayName dan searchTokens membantu pencarian', () {
      const item = GpuItem(
        model: 'ASUS RTX 4060 Dual - 8GB GDDR6',
        price: 4500000,
      );
      expect(item.displayName, 'ASUS RTX 4060 Dual');
      expect(item.searchTokens, containsAll(['asus', 'rtx', '4060', '8gb']));
    });
  });
}
