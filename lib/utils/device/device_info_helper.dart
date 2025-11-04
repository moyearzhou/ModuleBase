import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:module_base/utils/log/app_log_event.dart';
import 'app_info_service.dart';

class DeviceService {

  // 初始化所有服务
  static Future<void> initialize() async {
    await AppInfoService.initialize();
  }

  // 获取设备基本信息
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceInfo();
      } else {
        return _getBasicDeviceInfo();
      }
    } catch (e) {
      return _getBasicDeviceInfo();
    }
  }

  // 获取 Android 设备信息
  static Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await requiresDeviceInfo().androidInfo;

    return {
      'platform': 'android',
      'model': androidInfo.model,
      'brand': androidInfo.brand,
      'device': androidInfo.device,
      'product': androidInfo.product,
      'hardware': androidInfo.hardware,
      'manufacturer': androidInfo.manufacturer,
      'version': {
        'sdkInt': androidInfo.version.sdkInt,
        'release': androidInfo.version.release,
        'previewSdkInt': androidInfo.version.previewSdkInt,
        'incremental': androidInfo.version.incremental,
        'codename': androidInfo.version.codename,
        'baseOS': androidInfo.version.baseOS,
      },
      'board': androidInfo.board,
      'bootloader': androidInfo.bootloader,
      'display': androidInfo.display,
      'fingerprint': androidInfo.fingerprint,
      'host': androidInfo.host,
      'id': androidInfo.id,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
      'tags': androidInfo.tags,
      'type': androidInfo.type,
    };
  }

  // 获取 iOS 设备信息
  static Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    IosDeviceInfo iosInfo = await requiresDeviceInfo().iosInfo;

    return {
      'platform': 'ios',
      'model': iosInfo.model,
      'name': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'utsname': {
        'sysname': iosInfo.utsname.sysname,
        'nodename': iosInfo.utsname.nodename,
        'release': iosInfo.utsname.release,
        'version': iosInfo.utsname.version,
        'machine': iosInfo.utsname.machine,
      },
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
      'identifierForVendor': iosInfo.identifierForVendor,
    };
  }

  // 基础设备信息（备用）
  static Map<String, dynamic> _getBasicDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'localHostname': Platform.localHostname,
    };
  }

  // 获取应用信息 - 现在使用 AppInfoService
  static Future<Map<String, dynamic>> getAppInfo() async {
    final appInfo = await AppInfoService.getAllAppInfo();

    return {
      'appName': appInfo['appName'] ?? 'unknown',
      'packageName': appInfo['packageName'] ?? 'unknown',
      'version': appInfo['version'] ?? 'unknown',
      'buildNumber': appInfo['buildNumber'] ?? 'unknown',
      'buildSignature': appInfo['buildSignature'] ?? 'unknown',
      'fullVersion': AppInfoService.fullVersion,
    };
  }

  // 获取应用版本（便捷方法）
  static String get appVersion => AppInfoService.version;

  // 获取构建号（便捷方法）
  static String get buildNumber => AppInfoService.buildNumber;

  // 获取完整版本号（便捷方法）
  static String get fullVersion => AppInfoService.fullVersion;

  // 获取网络类型
  static Future<String> getNetworkType() async {
    try {
      var connectivityResult = await requiresConnectivity().checkConnectivity();

      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          return 'wifi';
        case ConnectivityResult.mobile:
          return 'cellular';
        case ConnectivityResult.ethernet:
          return 'ethernet';
        case ConnectivityResult.vpn:
          return 'vpn';
        case ConnectivityResult.bluetooth:
          return 'bluetooth';
        case ConnectivityResult.other:
          return 'other';
        default:
          return 'offline';
      }
    } catch (e) {
      return 'unknown';
    }
  }

  // 监听网络状态变化
  static Stream<String> get onNetworkStateChanged {
    return requiresConnectivity().onConnectivityChanged.map((result) {
      switch (result) {
        case ConnectivityResult.wifi:
          return 'wifi';
        case ConnectivityResult.mobile:
          return 'cellular';
        case ConnectivityResult.ethernet:
          return 'ethernet';
        case ConnectivityResult.vpn:
          return 'vpn';
        case ConnectivityResult.bluetooth:
          return 'bluetooth';
        case ConnectivityResult.other:
          return 'other';
        default:
          return 'offline';
      }
    });
  }

  // 获取设备唯一标识
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await requiresDeviceInfo().androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await requiresDeviceInfo().iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_id';
      } else {
        return 'unknown_platform';
      }
    } catch (e) {
      return 'error_getting_device_id';
    }
  }
}