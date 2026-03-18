import 'package:flutter/services.dart';

abstract interface class AssetLoader {
  Future<bool> exists(String assetPath);
}

class RootBundleAssetLoader implements AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<bool> exists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
