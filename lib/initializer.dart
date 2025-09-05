import 'package:module_base/stores/hive_stores.dart';
import 'package:module_base/utils/store/iface.dart';

class BaseInitializer {

  static void addStore(String key, HiveStore store)  {
    Stores.map[key] = store;
  }

  static Future<void> init() async {
    await PrefStore.shared.init();
    await Stores.init();
  }

}