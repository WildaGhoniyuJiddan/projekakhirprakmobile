/// Parser spesifikasi ringan dari nama model katalog.
///
/// Katalog retail hanya menyediakan `model` dan `price`; parser ini
/// mengekstrak informasi yang benar-benar tertulis di nama model.
abstract final class SpecParser {
  static Map<String, String> parse(String category, String model) {
    final text = model.toUpperCase();
    final specs = <String, String>{};

    switch (category) {
      case 'gpu':
        _put(specs, 'VRAM', _match(text, r'(\d{1,2}\s?GB)'));
        _put(specs, 'Memori', _match(text, r'(GDDR\d[A-Z]?)'));
        _put(
          specs,
          'Brand',
          _match(
            text,
            r'^(ASUS|MSI|GIGABYTE|ASROCK|ZOTAC|GALAX|PALIT|SAPPHIRE|XFX|INTEL|NVIDIA|AMD|POWERCOLOR|MANLI)',
          ),
        );
      case 'cpu':
        _put(specs, 'Socket', _match(text, r'(AM4|AM5|LGA\s?\d{3,4})'));
        _put(specs, 'Core', _match(text, r'(\d{1,2})\s?CORE'));
        _put(specs, 'Thread', _match(text, r'(\d{1,3})\s?THREAD'));
        _put(specs, 'Boost', _match(text, r'(\d(?:\.\d)?\s?GHZ)'));
        _put(specs, 'Brand', _match(text, r'^(AMD|INTEL)'));
      case 'motherboard':
        _put(specs, 'Socket', _match(text, r'(AM4|AM5|LGA\s?\d{3,4})'));
        _put(
          specs,
          'Chipset',
          _match(
            text,
            r'(A520|A620|B450|B550|B650|B760|B840|H610|H81|H310|H410|H510|X470|X570|X670|Z690|Z790)[A-Z]*',
          ),
        );
      case 'ram':
        _put(specs, 'Kapasitas', _match(text, r'(\d{1,3}\s?GB)'));
        _put(specs, 'Kecepatan', _match(text, r'(\d{4,5}\s?MHZ)'));
        _put(specs, 'Tipe', _match(text, r'(DDR[345])'));
      case 'storage':
        _put(specs, 'Kapasitas', _match(text, r'(\d{1,4}\s?(?:GB|TB))'));
        _put(specs, 'Interface', _match(text, r'(NVME|SATA|M\.2)'));
    }

    if (specs.isEmpty) {
      specs['Spesifikasi'] = 'Mengikuti model: ${_shortModel(model)}';
    }
    return specs;
  }

  static String? _match(String text, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
    return match?.group(1)?.trim().replaceAll(RegExp(r'\s+'), '');
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
