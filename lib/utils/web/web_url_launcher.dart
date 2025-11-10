import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class WebUrlLauncher {

  static Future<bool> Function(String url)? _harmonyWebLauncher;

  static void registerHarmonyWebLauncher(Future<bool> Function(String url)? launcher) {
    _harmonyWebLauncher = launcher;
  }

  static Future<void> launch(String url, {
    Function(Exception e)? onError
  }) async {

    try {
      var res = false;

      if (Platform.operatingSystem == "ohos") {
        if (_harmonyWebLauncher == null) {
          throw Exception('Harmony Web Launcher is not registered');
        }

        res = await _harmonyWebLauncher?.call(url) ?? false;
      } else {
        final Uri uri = Uri.parse(url);
        res = await canLaunchUrl(uri);
      }
      if (!res) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("访问网页失败: $e");
      onError?.call(Exception('Could not launch $url, $e'));
    }
  }
}