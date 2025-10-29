import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZoteroChannel {
  static const _zoteroChannelName = "com.moyear.zotpaper/app";  // 1.方法通道名称
  static const MethodChannel _channel = MethodChannel(_zoteroChannelName);

  static Future<String> getUserName() async {
    String userName = "";
    try {
      final String result = await _channel.invokeMethod('getUserName');
      userName = result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get user name: '${e.message}'.");
    }
    return userName;
  }


  static signOut() {
    _channel.invokeMethod('signOut');
  }

  /// 从 Android 原生获取 Map<String, String> 数据
  static Future<Map<String, String>?> getLocalCredentialV1() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getLocalCredentialV1');
      // 将 dynamic Map 转换为 String, String Map
      return result.cast<String, String>();
    } on PlatformException catch (e) {
      debugPrint("获取原生数据失败: '${e.message}'");
      return null;
    }
  }

}
