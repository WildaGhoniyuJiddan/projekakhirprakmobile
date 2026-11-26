/// Ekstraksi kunci seri dari nama model katalog.
///
/// Dipakai bersama oleh `CatalogItem.referencePrice` dan `CatalogService`
/// agar grouping etalase dan harga referensi memakai definisi seri yang sama.
abstract final class SeriesKey {
  static final _whitespaceRe = RegExp(r'\s+');
  static final _gpuRe = RegExp(
    r'\b(?:RTX|GTX|RX|ARC)\s?\d{3,4}\s?(?:TI|XT|SUPER)?\b',
  );
  static final _cpuPatterns = <RegExp>[
    RegExp(r'RYZEN\s?[3579]\s?\d{4}[A-Z0-9]*'),
    RegExp(r'CORE\s?ULTRA\s?[579]\s?\d{3}[A-Z]*'),
    RegExp(r'CORE\s?I[3579][- ]?\d{4,5}[A-Z0-9]*'),
    RegExp(r'ATHLON\s?\d{4}[A-Z]*'),
    RegExp(r'EPYC\s?\d{4}[A-Z0-9]*'),
    RegExp(r'THREADRIPPER(?:\s?PRO)?\s?\d{4}[A-Z]*'),
    RegExp(r'XEON\s?[A-Z0-9-]+'),
    RegExp(r'PENTIUM\s?(?:GOLD\s?)?[A-Z]?\d{4}[A-Z]*'),
  ];
  static final _moboRe = RegExp(
    r'(?:A520|A620A?|B450|B550|B650|B760|B840|H610|H81|B85|H110|H310|H410|H510|B250|B360|B460|Z490|Z590|X470|X570|X670|Z690|Z790|X299|TRX40|X399|WRX80)',
  );
  static final _ramTypeRe = RegExp(r'(DDR[345])');
  static final _ramCapacityRe = RegExp(r'(\d{1,3})\s?GB');
  static final _ramSpeedRe = RegExp(r'(\d{4,5})\s?MHZ');
  static final _storageCapacityRe = RegExp(r'(\d{1,4}\s?(?:GB|TB))');
  static final _nvmeRe = RegExp(r'(NVME)');
  static final _sataRe = RegExp(r'(SATA)');
  static final _hddRe = RegExp(r'(HDD)');
  static final _m2Re = RegExp(r'(M\.2)');
  static final _intelCoreTokenRe = RegExp(r'^I[3579](?=[-_]|$)');

  static String of(String section, String model) {
    final upper = model.toUpperCase().trim();
    if (upper.isEmpty) return upper;

    final key = switch (section) {
      'gpu' => _gpu(upper),
      'cpu' => _cpu(upper),
      'motherboard' => _motherboard(upper),
      'ram' => _ram(upper),
      'storage' => _storage(upper),
      _ => upper,
    };
    return key.trim().replaceAll(_whitespaceRe, ' ');
  }

  /// Nama seri yang ramah dibaca untuk kartu etalase.
  static String display(String section, String key) {
    if (key.isEmpty) return key;
    return switch (section) {
      'gpu' => _mapTokens(key, _gpuLabels),
      'cpu' => _mapTokens(key, _cpuLabels),
      'ram' => key.replaceAll('MHZ', 'MHz'),
      'storage' => key.replaceAll('NVME', 'NVMe'),
      _ => key,
    };
  }

  static String _gpu(String model) {
    final match = _gpuRe.firstMatch(model);
    return match?.group(0) ?? model;
  }

  static String _cpu(String model) {
    for (final pattern in _cpuPatterns) {
      final match = pattern.firstMatch(model);
      if (match != null) return match.group(0)!;
    }
    return model;
  }

  static String _motherboard(String model) {
    final match = _moboRe.firstMatch(model);
    return match?.group(0) ?? model;
  }

  static String _ram(String model) {
    final type = _group(model, _ramTypeRe);
    final capacity = _group(model, _ramCapacityRe);
    final speed = _group(model, _ramSpeedRe);

    final key = [
      ?type,
      if (capacity != null) '${capacity}GB',
      if (speed != null) '${speed}MHZ',
    ].join(' ');
    return key.isEmpty ? model : key;
  }

  static String _storage(String model) {
    final capacity = _group(
      model,
      _storageCapacityRe,
    )?.replaceAll(' ', '').toUpperCase();
    final interface =
        _group(model, _nvmeRe) ??
        _group(model, _sataRe) ??
        _group(model, _hddRe) ??
        _group(model, _m2Re);

    final key = [?interface, ?capacity].join(' ');
    return key.isEmpty ? model : key;
  }

  static String? _group(String model, RegExp pattern) {
    final match = pattern.firstMatch(model);
    if (match == null) return null;
    return (match.groupCount >= 1 ? match.group(1) : match.group(0))?.trim();
  }

  static String _mapTokens(String key, Map<String, String> labels) {
    return key
        .split(' ')
        .map((token) {
          if (_intelCoreTokenRe.hasMatch(token)) {
            return 'i${token.substring(1)}';
          }
          return labels[token] ?? token;
        })
        .join(' ');
  }

  static const _gpuLabels = {
    'RTX': 'RTX',
    'GTX': 'GTX',
    'RX': 'RX',
    'XT': 'XT',
    'TI': 'Ti',
    'SUPER': 'Super',
    'ARC': 'Arc',
  };

  static const _cpuLabels = {
    'RYZEN': 'Ryzen',
    'CORE': 'Core',
    'ULTRA': 'Ultra',
    'ATHLON': 'Athlon',
    'EPYC': 'EPYC',
    'XEON': 'Xeon',
    'THREADRIPPER': 'Threadripper',
    'PENTIUM': 'Pentium',
    'GOLD': 'Gold',
  };
}
