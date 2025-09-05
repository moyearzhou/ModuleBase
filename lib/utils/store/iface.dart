import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:module_base/ext/num.dart';
import 'package:module_base/ext/string.dart';
import 'package:module_base/utils/store/secure.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../build.dart';
import '../../ext/datetime.dart';
import '../platform/base.dart';
import '../platform/path.dart';

part 'hive.dart';
part 'pref.dart';

/// {@template store_from_to_str}
/// If there is a type which is not supported by the store, the store will call
/// this function to convert the value(string) between the type.
///
/// Call it as `XxxStr` to avoid the conflict with the `toString` method.
/// {@endtemplate}
typedef StoreFromStr<T extends Object> = T? Function(String rawString);

/// {@macro store_from_to_str}
typedef StoreToStr<T extends Object> = String? Function(T? value);

/// The interface of any [Store].
///
/// The provider of the store can be `shared_preferences`, `hive`, `sqflite`, etc.
///
/// {@template store_last_update_ts}
/// The last update timestamp is used to check whether the data's has been updated.
///
/// It's designed that only one timestamp for all the data in one store.
/// {@endtemplate}
sealed class Store {
  /// Get the key for the last update timestamp.
  final String lastUpdateTsKey;

  /// {@template store_updateLastUpdateTsOn}
  /// Whether to update the last update timestamp when modifying the store. 
  /// Default is [StoreDefaults.defaultUpdateLastUpdateTs].
  /// {@endtemplate}
  final bool updateLastUpdateTsOnSet;

  /// {@macro store_updateLastUpdateTsOn}
  final bool updateLastUpdateTsOnRemove;

  /// {@macro store_updateLastUpdateTsOn}
  final bool updateLastUpdateTsOnClear;

  const Store({
    this.updateLastUpdateTsOnSet = StoreDefaults.defaultUpdateLastUpdateTs,
    this.updateLastUpdateTsOnRemove = StoreDefaults.defaultUpdateLastUpdateTs,
    this.updateLastUpdateTsOnClear = StoreDefaults.defaultUpdateLastUpdateTs,
    this.lastUpdateTsKey = StoreDefaults.defaultLastUpdateTsKey,
  });

  /// Get the value of the key.
  ///
  /// If [T] is specified, the store will try to convert the value to [T] by
  /// calling [fromStr].
  T? get<T extends Object>(String key, {StoreFromStr<T>? fromStr});

  /// Set the value of the key.
  ///
  /// - If [T] is specified, the store will try to convert the value to string by
  /// calling [toStr].
  /// - If you want to set to `null`, use [remove] instead.
  FutureOr<bool> set<T extends Object>(
    String key,
    T val, {
    StoreToStr<T>? toStr,
    bool? updateLastUpdateTsOnSet,
  });

  /// Get all keys.
  ///
  /// {@template store_include_internal_keys}
  /// - [includeInternalKeys] is whether to include the internal keys.
  /// {@endtemplate}
  FutureOr<Set<String>> keys({bool includeInternalKeys = StoreDefaults.defaultIncludeInternalKeys});

  /// Remove the key.
  FutureOr<bool> remove(String key, {bool? updateLastUpdateTsOnRemove});

  /// Clear the store.
  FutureOr<bool> clear({bool? updateLastUpdateTsOnClear});

  /// Update the last update timestamp.
  ///
  /// You can override the timestamp by passing [ts].
  ///
  /// {@macro store_last_update_ts}
  FutureOr<void> updateLastUpdateTs([int? ts]) {
    if (!updateLastUpdateTsOnSet) return null;
    return set(lastUpdateTsKey, ts ?? DateTimeX.timestamp, updateLastUpdateTsOnSet: false);
  }

  /// Get the last update timestamp.
  ///
  /// {@macro store_last_update_ts}
  DateTime? get lastUpdateTs {
    final ts = get<int>(lastUpdateTsKey);
    if (ts == null) return null;
    return ts.tsToDateTime;
  }

  /// Whether the key is an internal key.
  bool isInternalKey(String key) {
    return key.startsWith(StoreDefaults.prefixKey) || key.startsWith(StoreDefaults.prefixKeyOld);
  }

  /// Get all the key-value pairs.
  ///
  /// If you want a map result, use [getAllMap] instead.
  ///
  /// {@macro store_include_internal_keys}
  Stream<(String, Object?)> getAll({
    bool includeInternalKeys = StoreDefaults.defaultIncludeInternalKeys,
  }) async* {
    for (final key in await keys()) {
      if (!includeInternalKeys && isInternalKey(key)) {
        continue;
      }
      yield (key, get(key));
    }
  }

  /// Get all the key-value pairs as a map.
  ///
  /// If you want a stream result, use [getAll] instead.
  ///
  /// {@macro store_include_internal_keys}
  FutureOr<Map<String, Object?>> getAllMap({
    bool includeInternalKeys = StoreDefaults.defaultIncludeInternalKeys,
  }) async {
    final keys = await this.keys();
    if (!includeInternalKeys) {
      keys.removeWhere(isInternalKey);
    }
    final map = Map.fromIterables(keys, keys.map((key) => get(key)));
    return map;
  }

  /// Get all the key-value pairs as a [Map<T>].
  ///
  /// Generic version of [getAllMap].
  ///
  /// {@macro store_include_internal_keys}
  FutureOr<Map<String, T>> getAllMapTyped<T extends Object>({
    bool includeInternalKeys = StoreDefaults.defaultIncludeInternalKeys,
    StoreFromStr<T>? fromStr,
  }) async {
    final keys = await this.keys();
    if (!includeInternalKeys) {
      keys.removeWhere(isInternalKey);
    }
    final map = <String, T>{};
    for (final key in keys) {
      final val = get(key);
      if (val is T) {
        map[key] = val;
        continue;
      }
      if (val is String) {
        try {
          final converted = fromStr?.call(val);
          if (converted is T) {
            map[key] = converted;
            continue;
          }
        } catch (e) {
          dprintWarn('getAllMapTyped()', 'convert `$key`: $e');
        }
      }
    }
    return map;
  }

  /// Format the warning msg.
  String fmtWarnMsg(String fn, String msg) {
    return '$runtimeType.$fn $msg';
  }

  /// Print the formatted warning msg.
  void dprintWarn(String fn, String msg) {
    dprint(fmtWarnMsg(fn, msg));
  }
}

/// The interface of a single Property in any [Store].
///
/// Such as the `user_token` in `shared_preferences`, `user` in `hive`, etc.
abstract class StoreProp<T extends Object> {
  /// The key of the property.
  final String key;

  /// Convert the value(string) to [T].
  final StoreFromStr<T>? fromStr;

  /// Convert the value to string.
  final StoreToStr<T>? toStr;

  /// Whether to update the last update timestamp when setting a value for this property.
  ///
  /// {@macro store_last_update_ts}
  final bool updateLastUpdateTsOnSetProp;

  /// {@template store_prop_constructor}
  /// Constructor.
  ///
  /// - [key] is the key of the property.
  /// - [fromStr] & [toStr], you can refer to [StoreFromStr] & [StoreToStr].
  /// - [store] is the store of the property.
  /// - [updateLastUpdateTsOnSetProp] is whether to update the last update timestamp
  /// of this [Store] when setting a value for this property.
  /// {@endtemplate}
  const StoreProp(
    this.key, {
    this.fromStr,
    this.toStr,
    this.updateLastUpdateTsOnSetProp = StoreDefaults.defaultUpdateLastUpdateTs,
  });

  /// It's [Store].
  Store get store;

  /// Get the value of the key.
  T? get() => store.get(key, fromStr: fromStr);

  /// Set the value of the key.
  ///
  /// If you want to set `null`, use `remove()` instead.
  FutureOr<void> set(T value) => store.set(key, value, toStr: toStr, updateLastUpdateTsOnSet: updateLastUpdateTsOnSet);

  /// Remove the key.
  FutureOr<void> remove() => store.remove(key);

  /// {@template store_prop_listenable}
  /// Get the [ValueListenable] of the key.
  ///
  /// It's used to listen to the value changes.
  /// {@endtemplate}
  ValueListenable<T?> listenable();

  /// Whether to update the last update timestamp when setting a value depends on
  /// both [updateLastUpdateTsOnSetProp] && [updateLastUpdateTsOnSet].
  ///
  /// {@macro store_last_update_ts}
  bool get updateLastUpdateTsOnSet => store.updateLastUpdateTsOnSet && updateLastUpdateTsOnSetProp;
}

/// The interface of a single Property in any [Store] which has a default value.
///
/// Such as the `user_token` in `shared_preferences`, `user` in `hive`, etc.
abstract class StorePropDefault<T extends Object> extends StoreProp<T> {
  /// The default value of the property.
  final T defaultValue;

  /// Constructor.
  ///
  /// - [key] is the key of the property.
  /// - [defaultValue] is the default value of the property.
  /// - [fromStr] & [toStr], you can refer to [StoreFromStr] & [StoreToStr].
  const StorePropDefault(
    super.key,
    this.defaultValue, {
    super.fromStr,
    super.toStr,
    super.updateLastUpdateTsOnSetProp = StoreDefaults.defaultUpdateLastUpdateTs,
  });

  /// Get the value of the key.
  @override
  T get() => store.get(key, fromStr: fromStr) ?? defaultValue;

  /// Set the value of the key.
  @override
  FutureOr<void> set(T value) => store.set(key, value, toStr: toStr, updateLastUpdateTsOnSet: updateLastUpdateTsOnSet);

  /// {@macro store_prop_listenable}
  @override
  ValueListenable<T> listenable();
}

/// The keys used internally in the store.
extension StoreDefaults on Store {
  /// {@template store_defaults_prefix_key}
  /// The prefix of the internal keys.
  ///
  /// If you want to export data from the store, you can ignore the keys with this prefix.
  /// {@endtemplate}
  static const prefixKey = '__lkpt_';

  /// {@macro store_defaults_prefix_key}
  static const prefixKeyOld = '_sbi_';

  /// The key for the last update timestamp.
  static const defaultLastUpdateTsKey = '${prefixKey}lastUpdateTs';

  /// Update the last update timestamp by default.
  static const defaultUpdateLastUpdateTs = true;

  /// NOT Include the internal keys by default.
  static const defaultIncludeInternalKeys = false;
}
