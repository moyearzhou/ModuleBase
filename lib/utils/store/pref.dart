part of 'iface.dart';

/// Properties saved in SharedPreferences.
abstract final class PrefProps {
  /// Used for migration
  static const lastVer = PrefPropDefault<int>('last_ver', 0);

  /// `null` means not set, `''` means empty password
  static const bakPwd = PrefProp<String>('bak_pwd');

  /// Soft IME suggestions
  static const imeSuggestions = PrefProp<bool>('ime_suggestions');

  /// {@template webdav_settings}
  /// WebDAV settings
  /// {@endtemplate}
  static const webdavUrl = PrefProp<String>('webdav_url');

  /// {@macro webdav_settings}
  static const webdavUser = PrefProp<String>('webdav_user');

  /// {@macro webdav_settings}
  static const webdavPwd = PrefProp<String>('webdav_pwd');

  /// {@macro webdav_settings}
  static const webdavSync = PrefPropDefault('webdav_sync', false);

  /// iCloud sync
  static const icloudSync = PrefPropDefault('icloud_sync', false);
}

/// The listener of the SharedPreferences.
///
/// - [key] is the changed key.
typedef PrefStoreKeyListener = void Function(String key);

/// SharedPreferences store.
///
/// {@template PrefStore.init}
/// `MUST` call [init] before using any pref stores.
/// {@endtemplate}
final class PrefStore extends Store {
  /// The prefix of SharedPreferences.
  ///
  /// Defaults to `''`.
  final String? prefix;

  /// Value changes listeners.
  final Set<PrefStoreKeyListener> listeners;

  /// Due to the limit of the SharedPreferences singleton, only [shared] is recommended.
  ///
  /// {@macro PrefStore.init}
  PrefStore({
    this.prefix,
    Set<PrefStoreKeyListener>? listeners,
    super.updateLastUpdateTsOnSet,
    super.lastUpdateTsKey,
  }) : listeners = listeners ?? {};

  /// Single instance for the whole app.
  ///
  /// - The [prefix] is `''`.
  static final shared = PrefStore();

  SharedPreferences? _instance;

  /// Initialize the store.
  ///
  /// `MUST` call this before using any pref stores.
  Future<void> init({String prefix = ''}) async {
    if (_instance != null) return;
    SharedPreferences.setPrefix(prefix);
    _instance = await SharedPreferences.getInstance();
  }

  /// Get the value of the key.
  ///
  /// {@template pref_store_types}
  /// Only support types: [bool], [double], [int], [String], `List<String>`.
  /// {@endtemplate}
  @override
  T? get<T extends Object>(String key, {StoreFromStr<T>? fromStr}) {
    final val = _instance!.get(key);
    if (val is! T) {
      if (val == null) return null;
      if (val is String && fromStr != null) {
        return fromStr(val);
      }
      dprintWarn('get("$key")', 'is: ${val.runtimeType}');
      return null;
    }
    return val;
  }

  /// Set the value of the key.
  ///
  /// {@macro pref_store_types}
  @override
  Future<bool> set<T extends Object>(
    String key,
    T val, {
    StoreToStr<T>? toStr,
    bool? updateLastUpdateTsOnSet,
  }) {
    final res = switch (val) {
      final bool val => _instance!.setBool(key, val),
      final double val => _instance!.setDouble(key, val),
      final int val => _instance!.setInt(key, val),
      final String val => _instance!.setString(key, val),
      final List<String> val => _instance!.setStringList(key, val),
      _ => () {
          if (toStr != null) {
            final str = toStr(val);
            if (str is String) return _instance!.setString(key, str);
          }
          dprintWarn('set("$key")', 'invalid type: ${val.runtimeType}');
          return Future.value(false);
        }(),
    };
    if (updateLastUpdateTsOnSet ?? this.updateLastUpdateTsOnSet) updateLastUpdateTs();
    return res;
  }

  /// Get all keys.
  @override
  Future<Set<String>> keys({bool includeInternalKeys = StoreDefaults.defaultIncludeInternalKeys}) =>
      Future.value(_instance!.getKeys());

  /// Remove the key.
  @override
  Future<bool> remove(String key, {bool? updateLastUpdateTsOnRemove}) {
    updateLastUpdateTsOnRemove ??= this.updateLastUpdateTsOnRemove;
    final ret = _instance!.remove(key);
    if (updateLastUpdateTsOnRemove) updateLastUpdateTs();
    return ret;
  }

  /// Clear the store.
  @override
  Future<bool> clear({bool? updateLastUpdateTsOnClear}) {
    final ret = _instance!.clear();
    updateLastUpdateTsOnClear ??= this.updateLastUpdateTsOnClear;
    if (updateLastUpdateTsOnClear) updateLastUpdateTs();
    return ret;
  }
}

/// A single Property in SharedPreferences.
///
/// {@macro pref_store_types}
///
/// You can define a property like this:
/// ```dart
/// const userToken = PrefProp<String>('user_token');
/// ```
final class PrefProp<T extends Object> extends StoreProp<T> {
  final PrefStore? _store;

  const PrefProp(
    super.key, {
    PrefStore? store,
    super.fromStr,
    super.toStr,
    super.updateLastUpdateTsOnSetProp,
  }) : _store = store;

  @override
  PrefStore get store => _store ?? PrefStore.shared;

  @override
  ValueListenable<T?> listenable() => PrefPropListenable<T>(store, key);

  /// Override it, so the return type is `T?` instead of `FutureOr<T?>`.
  @override
  T? get() => store.get<T>(key);
}

/// A single Property in SharedPreferences with default value.
///
/// {@macro pref_store_types}
///
/// You can define a property like this:
/// ```dart
/// const userToken = PrefPropDefault<String>('user_token', 'default_token');
/// ```
final class PrefPropDefault<T extends Object> extends StorePropDefault<T> {
  final PrefStore? _store;

  const PrefPropDefault(
    super.key,
    super.defaultValue, {
    PrefStore? store,
    super.fromStr,
    super.toStr,
    super.updateLastUpdateTsOnSetProp,
  }) : _store = store;

  @override
  PrefStore get store => _store ?? PrefStore.shared;

  @override
  ValueListenable<T> listenable() => PrefPropDefaultListenable<T>(store, key, defaultValue);
}

/// The [ValueListenable] of the key.
final class PrefPropListenable<T extends Object> extends ValueListenable<T?> {
  final PrefStore store;
  final String key;

  const PrefPropListenable(this.store, this.key);

  @override
  void addListener(VoidCallback listener) {
    store.listeners.add((k) {
      if (k == key) listener();
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    store.listeners.removeWhere((element) {
      return element == listener;
    });
  }

  @override
  T? get value => store.get<T>(key);
}

/// The [ValueListenable] of the key with default value.
final class PrefPropDefaultListenable<T extends Object> extends ValueListenable<T> {
  final PrefStore store;
  final String key;
  final T defaultValue;

  /// The internal map of prop key listeners.
  final _map = <int, PrefStoreKeyListener>{};

  PrefPropDefaultListenable(this.store, this.key, this.defaultValue);

  @override
  void addListener(VoidCallback listener) {
    final lis = _map.putIfAbsent(listener.hashCode, () {
      // The actual listener
      void lis(String k) {
        if (k == key) listener();
      }

      return lis;
    });
    store.listeners.add(lis);
  }

  @override
  void removeListener(VoidCallback listener) {
    store.listeners.removeWhere((element) {
      // Find the actual listener by [hashCode]
      return element == _map.remove(listener.hashCode);
    });
  }

  @override

  /// Since the value is retrieved from the store, so the value is not guaranteed
  /// to be the same as expected(the actual modified value).
  T get value => store.get<T>(key) ?? defaultValue;
}
