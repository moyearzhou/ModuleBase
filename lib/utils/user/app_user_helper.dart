import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppUserHelper {

  static String? userUUID = null;

  static Future<String> getUUID() async {
    if (userUUID != null) {
      return userUUID!;
    }

    // 从sp中获取uuid，如果没有则生成，保存到sp中
    final prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString('user_uuid') ?? "";
    if (uuid.isEmpty) {
      uuid = const Uuid().v4(); // 需要添加 uuid 包依赖
      await prefs.setString('user_uuid', uuid);
    }
    userUUID = uuid;
    return uuid;
  }
}