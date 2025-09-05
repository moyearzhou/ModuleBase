part of 'iface.dart';

/// The store of Hive.
///
/// It implements [Store].
class HiveStore extends Store {
  /// The internal hive box for this [Store].
  late final Box box;

  /// The name of the box. Used for the hive box.
  final String boxName;

  /// Constructor.
  HiveStore(this.boxName, {super.lastUpdateTsKey = '_sbi_lastModified'});

  /// Initialize the [HiveStore].
  Future<void> init() async {
    if (SecureStore.cipher == null) await SecureStore.init();

    final path = switch (Pfs.type) {
      /// The default path of Hive is the HOME dir
      Pfs.linux || Pfs.windows => Paths.doc,
      _ => (await getApplicationDocumentsDirectory()).path,
    };

    final enc = await Hive.openBox(
      '${boxName}_enc',
      path: path,
      encryptionCipher: SecureStore.cipher,
    );

    final unencryptedFile = File('${path.joinPath(boxName)}.hive');
    if (await unencryptedFile.exists()) {
      // Do migration
      try {
        final unencrypted = await Hive.openBox(boxName, path: path);
        for (final key in unencrypted.keys) {
          enc.put(key, unencrypted.get(key));
        }
        await unencrypted.close();
        await unencryptedFile.delete();
        dprint('Migrated $boxName');
      } catch (e) {
        dprint('Failed to migrate $boxName: $e');
      }
    }

    box = enc;
  }

  /// A property of the [HiveStore].
  HiveProp<T> property<T extends Object>(
    String key, {
    T? defaultValue,
    bool updateLastModified = true,
    T? Function(String)? fromStr,
    String? Function(T?)? toStr,
  }) {
    return HiveProp<T>(
      this,
      key,
      updateLastUpdateTsOnSetProp: updateLastModified,
      fromStr: fromStr,
      toStr: toStr,
    );
  }

  HivePropDefault<T> propertyDefault<T extends Object>(
    String key,
    T defaultValue, {
    bool updateLastModified = StoreDefaults.defaultUpdateLastUpdateTs,
    T? Function(String)? fromStr,
    String? Function(T?)? toStr,
  }) {
    return HivePropDefault<T>(
      this,
      key,
      defaultValue,
      updateLastUpdateTsOnSetProp: updateLastModified,
      fromStr: fromStr,
      toStr: toStr,
    );
  }

  @override
  T? get<T extends Object>(String key, {StoreFromStr<T>? fromStr}) {
    final val = box.get(key);
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

  @override
  bool set<T extends Object>(
    String key,
    T val, {
    StoreToStr<T>? toStr,
    bool? updateLastUpdateTsOnSet,
  }) {
    updateLastUpdateTsOnSet ??= this.updateLastUpdateTsOnSet;
    if (toStr != null) {
      final str = toStr(val);
      if (str is String) {
        box.put(key, str);
        if (updateLastUpdateTsOnSet) updateLastUpdateTs();
        return true;
      }
    }
    box.put(key, val);
    if (updateLastUpdateTsOnSet) updateLastUpdateTs();
    return true;
  }

  @override
  Set<String> keys({bool includeInternalKeys = StoreDefaults.defaultIncludeInternalKeys}) {
    final set_ = <String>{};
    for (final key in box.keys) {
      if (key is String) {
        set_.add(key);
      }
    }
    return set_;
  }

  @override
  bool remove(String key, {bool? updateLastUpdateTsOnRemove}) {
    box.delete(key);
    updateLastUpdateTsOnRemove ??= this.updateLastUpdateTsOnRemove;
    if (updateLastUpdateTsOnRemove) updateLastUpdateTs();
    return true;
  }

  @override
  bool clear({bool? updateLastUpdateTsOnClear}) {
    box.clear();
    updateLastUpdateTsOnClear ??= this.updateLastUpdateTsOnClear;
    if (updateLastUpdateTsOnClear) updateLastUpdateTs();
    return true;
  }
}

/// A property of the [HiveStore].
class HiveProp<T extends Object> extends StoreProp<T> {
  @override
  final HiveStore store;

  HiveProp(
    this.store,
    super.key, {
    super.updateLastUpdateTsOnSetProp,
    super.fromStr,
    super.toStr,
  });

  /// {@template hive_store_fn_backward_compatibility}
  /// It's preserved for backward compatibility.
  /// {@endtemplate}
  T? fetch() => get();

  /// {@macro hive_store_fn_backward_compatibility}
  void put(T value) => set(value);

  void delete() => super.remove();

  @override
  ValueListenable<T> listenable() {
    return HivePropListenable<T>(store.box, key, null);
  }
}

final class HivePropDefault<T extends Object> extends StorePropDefault<T> implements HiveProp<T> {
  @override
  final HiveStore store;

  HivePropDefault(
    this.store,
    super.key,
    super.defaultValue, {
    super.updateLastUpdateTsOnSetProp,
    super.fromStr,
    super.toStr,
  });

  @override
  ValueListenable<T> listenable() {
    return HivePropListenable<T>(store.box, key, defaultValue);
  }

  @override
  T fetch() => get();

  @override
  void put(T value) => set(value);

  @override
  void delete() => super.remove();
}

class HivePropListenable<T> extends ValueListenable<T> {
  HivePropListenable(this.box, this.key, this.defaultValue);

  final Box box;
  final String key;
  T? defaultValue;

  final List<VoidCallback> _listeners = [];
  StreamSubscription? _subscription;

  @override
  void addListener(VoidCallback listener) {
    _subscription ??= box.watch().listen((event) {
      if (key == event.key) {
        for (var listener in _listeners) {
          listener();
        }
      }
    });

    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  T get value {
    final val = box.get(key, defaultValue: defaultValue);
    if (val == null || val is! T) {
      return defaultValue!;
    }
    return val;
  }
}
