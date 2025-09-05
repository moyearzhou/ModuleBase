import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZoteroChannel {
  static const _zoteroChannelName = "com.moyear/zotero";  // 1.方法通道名称
  static const MethodChannel _batteryChannel = MethodChannel(_zoteroChannelName);

  static Future<String> getUserName() async {
    String userName = "";
    try {
      final String result = await _batteryChannel.invokeMethod('getUserName');
      userName = result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get user name: '${e.message}'.");
    }
    return userName;
  }


  static signOut() {
    _batteryChannel.invokeMethod('signOut');
  }

}
