import 'dart:convert';

import 'package:hive/hive.dart';

import 'iface.dart';

/// The secure store.
///
/// It uses system built-in vault to store the data.
abstract final class SecureStore {
  /// The cipher of the [HiveStore].
  static HiveAesCipher? cipher;

  static const _hiveKey = 'hive_key';

  /// The encryption key of the [HiveStore].
  static Future<String?> get encryptionKey async {
    final hiveKey = PrefStore.shared.get<String>(_hiveKey);
    if (hiveKey != null) return hiveKey;
    return PrefStore.shared.get<String>('flutter.$_hiveKey');
  }

  /// Initialize the [SecureStore].
  static Future<void> init() async {
    final encryptionKeyString = await encryptionKey;
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await PrefStore.shared.set(_hiveKey, base64UrlEncode(key));
    }
    final key = await encryptionKey;
    if (key == null) {
      throw Exception('Failed to init SecureStore');
    }
    final encryptionKeyUint8List = base64Url.decode(key);
    cipher = HiveAesCipher(encryptionKeyUint8List);
  }
}
