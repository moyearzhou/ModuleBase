import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PlatformStorageProvider {

  /// 获取应用数据的存储目录，根据不同的平台获取不同的目录
  static Future<Directory?> getStorageDir() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return getApplicationSupportDirectory();
    } else {
      // 鸿蒙等其他平台
      return await getExternalStorageDirectory();
    }
  }

}