/// Katalog kecil deterministik untuk widget test.
///
/// Pemuatan aset nyata tetap diuji di `test/services/catalog_service_test.dart`;
/// widget test memakai bundle ini agar tidak bergantung pada I/O aset.
const String sampleCatalogJson = '''
{
  "generated_at": "2026-01-01T00:00:00Z",
  "gpu": [
    {"model": "ASUS GeForce RTX 4060 8GB GDDR6 Dual", "price": 5000000},
    {"model": "MSI GeForce RTX 4060 8GB GDDR6 Ventus", "price": 4500000},
    {"model": "MAXSUN GeForce RTX 4060 8GB GDDR6 Terminator", "price": 4200000},
    {"model": "ASUS GeForce RTX 4060 Ti 8GB GDDR6 Dual", "price": 7500000},
    {"model": "MSI GeForce RTX 4060 Ti 8GB GDDR6 Ventus", "price": 7200000},
    {"model": "ASRock Radeon RX 7600 8GB GDDR6", "price": 3500000},
    {"model": "Sapphire Radeon RX 7600 8GB GDDR6", "price": 3600000}
  ],
  "cpu": [
    {"model": "AMD Ryzen 5 5600 3.5GHz 6 Core AM4", "price": 1900000},
    {"model": "AMD Ryzen 5 5600 3.5GHz 6 Core AM4 [Tray]", "price": 2000000},
    {"model": "AMD Ryzen 5 5600 3.5GHz 6 Core AM4 [Box]", "price": 2100000},
    {"model": "AMD Ryzen 7 5800X 3.8GHz 8 Core AM4", "price": 3400000},
    {"model": "AMD Ryzen 7 5800X 3.8GHz 8 Core AM4 [Box]", "price": 3500000}
  ],
  "motherboard": [
    {"model": "MSI PRO B550M-VC WIFI AM4", "price": 1400000},
    {"model": "ASUS TUF B550M-PLUS AM4", "price": 1600000},
    {"model": "ASRock B650M-HDV/M.2 AM5", "price": 1800000},
    {"model": "MSI PRO B650M-A WIFI AM5", "price": 2100000}
  ],
  "ram": [
    {"model": "ADATA DDR4 16GB 3200MHz", "price": 700000},
    {"model": "Corsair DDR4 16GB 3200MHz", "price": 750000},
    {"model": "ADATA DDR5 32GB 5600MHz", "price": 1800000}
  ],
  "storage": [
    {"model": "ADATA Legend 710 1TB NVMe M.2", "price": 900000},
    {"model": "Samsung 980 1TB NVMe M.2", "price": 1100000},
    {"model": "Seagate Barracuda 1TB HDD SATA", "price": 600000}
  ]
}
''';
