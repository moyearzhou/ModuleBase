import 'dart:collection';
import 'package:module_base/utils/store/iface.dart';

abstract final class Stores {
  static String KEY_LIBRARY = "store_library";
  static String KEY_SETTING = "store_settings";
  static String KEY_ATTACHMENT = "store_attachment";


  // static final history = HistoryStore();

  // static final setting = SettingStore();
  //
  // static final attachment = AttachmentStore();
  //
  // static final library = LibraryStore();

  // static final config = ConfigStore();
  // static final tool = ToolStore();


  static final Map<String, HiveStore> map = HashMap();


  static void put(String key, HiveStore store) {
    Stores.map[key] = store;
  }

  static void remove(String key) {
    // Stores.all.removeWhere((element) => element.name == key);
    Stores.map.remove(key);
  }


  static HiveStore? get(String key) {
    return Stores.map[key];
  }

  static Future<void> init() async {
    await Future.wait(map.values.map((e) => e.init()));
  }

  static DateTime? get lastModTime {
    DateTime? lastModTime_;
    for (final store in map.values) {
      final last = store.lastUpdateTs;
      if (last != null) {
        if (lastModTime_ == null || lastModTime_.isBefore(last)) {
          lastModTime_ = last;
        }
      }
    }
    return lastModTime_;
  }
}
