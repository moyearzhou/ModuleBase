import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  static PackageInfo? _packageInfo;
  static bool _isInitialized = false;

  // 初始化应用信息（建议在应用启动时调用）
  static Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
      debugPrint('应用信息初始化成功: ${_packageInfo!.version} (${_packageInfo!.buildNumber})');
    } catch (e) {
      debugPrint('应用信息初始化失败: $e');
      _isInitialized = false;
    }
  }

  // 获取应用版本号 (例如: 1.0.0)
  static String get version {
    if (!_isInitialized || _packageInfo == null) {
      return 'unknown';
    }
    return _packageInfo!.version;
  }

  // 获取构建号 (例如: 1)
  static String get buildNumber {
    if (!_isInitialized || _packageInfo == null) {
      return 'unknown';
    }
    return _packageInfo!.buildNumber;
  }

  // 获取应用名称
  static String get appName {
    if (!_isInitialized || _packageInfo == null) {
      return 'unknown';
    }
    return _packageInfo!.appName;
  }

  // 获取包名 (例如: com.example.app)
  static String get packageName {
    if (!_isInitialized || _packageInfo == null) {
      return 'unknown';
    }
    return _packageInfo!.packageName;
  }

  // 获取构建签名
  static String get buildSignature {
    if (!_isInitialized || _packageInfo == null) {
      return 'unknown';
    }
    return _packageInfo!.buildSignature;
  }

  // 获取完整的版本信息（包含构建号）
  static String get fullVersion {
    if (!_isInitialized || _packageInfo == null) {
      return 'unknown';
    }
    return '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }

  // 获取所有应用信息的 Map
  static Future<Map<String, String>> getAllAppInfo() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_packageInfo == null) {
      return {
        'appName': 'unknown',
        'packageName': 'unknown',
        'version': 'unknown',
        'buildNumber': 'unknown',
        'buildSignature': 'unknown',
      };
    }

    return {
      'appName': _packageInfo!.appName,
      'packageName': _packageInfo!.packageName,
      'version': _packageInfo!.version,
      'buildNumber': _packageInfo!.buildNumber,
      'buildSignature': _packageInfo!.buildSignature,
    };
  }

  // 检查是否为特定版本
  static bool isVersion(String version) {
    if (!_isInitialized || _packageInfo == null) {
      return false;
    }
    return _packageInfo!.version == version;
  }

  // 检查版本是否大于等于指定版本
  static bool isVersionAtLeast(String minVersion) {
    if (!_isInitialized || _packageInfo == null) {
      return false;
    }
    return _compareVersions(_packageInfo!.version, minVersion) >= 0;
  }

  // 比较版本号
  static int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // 确保两个版本号有相同数量的部分
    while (v1Parts.length < v2Parts.length) v1Parts.add(0);
    while (v2Parts.length < v1Parts.length) v2Parts.add(0);

    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }
}