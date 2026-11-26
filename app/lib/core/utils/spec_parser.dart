/// Parser spesifikasi ringan dari nama model katalog.
///
/// Katalog retail hanya menyediakan `model` dan `price`; parser ini
/// mengekstrak informasi yang benar-benar tertulis di nama model.
abstract final class SpecParser {
  static final _whitespaceRe = RegExp(r'\s+');
  static final _gpuVramRe = RegExp(r'(\d{1,2}\s?GB)', caseSensitive: false);
  static final _gpuMemoryRe = RegExp(r'(GDDR\d[A-Z]?)', caseSensitive: false);
  static final _gpuBrandRe = RegExp(
    r'^(ASUS|MSI|GIGABYTE|ASROCK|ZOTAC|GALAX|PALIT|SAPPHIRE|XFX|INTEL|NVIDIA|AMD|POWERCOLOR|MANLI)',
    caseSensitive: false,
  );
  static final _socketRe = RegExp(
    r'(AM4|AM5|LGA\s?\d{3,4})',
    caseSensitive: false,
  );
  static final _cpuCoreRe = RegExp(r'(\d{1,2})\s?CORE', caseSensitive: false);
  static final _cpuThreadRe = RegExp(
    r'(\d{1,3})\s?THREAD',
    caseSensitive: false,
  );
  static final _cpuBoostRe = RegExp(
    r'(\d(?:\.\d)?\s?GHZ)',
    caseSensitive: false,
  );
  static final _cpuBrandRe = RegExp(r'^(AMD|INTEL)', caseSensitive: false);
  static final _moboChipsetRe = RegExp(
    r'(A520|A620|B450|B550|B650|B760|B840|H610|H81|H310|H410|H510|X470|X570|X670|Z690|Z790)[A-Z]*',
    caseSensitive: false,
  );
  static final _ramCapRe = RegExp(r'(\d{1,3}\s?GB)', caseSensitive: false);
  static final _ramSpeedRe = RegExp(r'(\d{4,5}\s?MHZ)', caseSensitive: false);
  static final _ramTypeRe = RegExp(r'(DDR[345])', caseSensitive: false);
  static final _storageCapRe = RegExp(
    r'(\d{1,4}\s?(?:GB|TB))',
    caseSensitive: false,
  );
  static final _storageIfRe = RegExp(
    r'(NVME|SATA|M\.2)',
    caseSensitive: false,
  );

  static Map<String, String> parse(String category, String model) {
    final text = model.toUpperCase();
    final specs = <String, String>{};

    switch (category) {
      case 'gpu':
        _put(specs, 'VRAM', _match(text, _gpuVramRe));
        _put(specs, 'Memori', _match(text, _gpuMemoryRe));
        _put(specs, 'Brand', _match(text, _gpuBrandRe));
      case 'cpu':
        _put(specs, 'Socket', _match(text, _socketRe));
        _put(specs, 'Core', _match(text, _cpuCoreRe));
        _put(specs, 'Thread', _match(text, _cpuThreadRe));
        _put(specs, 'Boost', _match(text, _cpuBoostRe));
        _put(specs, 'Brand', _match(text, _cpuBrandRe));
      case 'motherboard':
        _put(specs, 'Socket', _match(text, _socketRe));
        _put(specs, 'Chipset', _match(text, _moboChipsetRe));
      case 'ram':
        _put(specs, 'Kapasitas', _match(text, _ramCapRe));
        _put(specs, 'Kecepatan', _match(text, _ramSpeedRe));
        _put(specs, 'Tipe', _match(text, _ramTypeRe));
      case 'storage':
        _put(specs, 'Kapasitas', _match(text, _storageCapRe));
        _put(specs, 'Interface', _match(text, _storageIfRe));
    }

    if (specs.isEmpty) {
      specs['Spesifikasi'] = 'Mengikuti model: ${_shortModel(model)}';
    }
    return specs;
  }

  static String? _match(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim().replaceAll(_whitespaceRe, '');
  }

  static void _put(Map<String, String> specs, String label, String? value) {
    if (value == null || value.isEmpty) return;
    specs[label] = value;
  }

  static String _shortModel(String model) {
    final short = model.split(' - ').first.trim();
    return short.isEmpty ? model : short;
  }
}
