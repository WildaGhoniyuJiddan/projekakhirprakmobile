import 'dart:convert';

import 'package:flutter/services.dart';

/// AssetBundle palsu untuk menguji parser tanpa file aset nyata.
class JsonAssetBundle extends CachingAssetBundle {
  JsonAssetBundle(this.json);

  final String json;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(json));
    return ByteData.sublistView(bytes);
  }
}
