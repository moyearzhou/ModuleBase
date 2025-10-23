import 'package:flutter/material.dart';
import 'package:webdav_client/webdav_client.dart';

class WebdavUtils {
  static Future<bool> testWebdav(
      String address,
      String userName,
      String password,
      ) async {
    try {
      var webdav = newClient(
        address,
        user: userName,
        password: password,
      );
      var res = await webdav.readDir("/");
      // await webdav.ping();
      return true;
    } catch (e) {
      debugPrint("testWebdav errror: $e");
      rethrow;
      // return false;
    }
  }
}

