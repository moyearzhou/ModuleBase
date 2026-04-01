import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:module_base/utils/device/device_utils.dart';
import 'app_info_service.dart';

class DeviceService {

  static Future<Map<String, dynamic>>? _harmonyDeviceInfoHook;

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
      } else if (Platform.operatingSystem == "ohos") {
        return await _getHarmonyDeviceInfo();
      } else if (Platform.isMacOS) {
        return await _getMacOSDeviceInfo();
      } else {
        return _getBasicDeviceInfo();
      }
    } catch (e) {
      return _getBasicDeviceInfo();
    }
  }

  // 获取 Android 设备信息
  static Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await DeviceUtils.requiresDeviceInfo().androidInfo;

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
    IosDeviceInfo iosInfo = await DeviceUtils.requiresDeviceInfo().iosInfo;

    return {
      'platform': 'ios',
      'brand': 'Apple',
      'model': iosInfo.model,
      'name': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'device': iosInfo.modelName,
      'product': iosInfo.modelName,
      'hardware': iosInfo.utsname.machine,
      'manufacturer': iosInfo.utsname.machine,
      'version': {
        'sdkInt': iosInfo.systemVersion,
        'release': iosInfo.utsname.release,
      },
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

  static Future<Map<String, dynamic>> _getMacOSDeviceInfo() async {
    MacOsDeviceInfo macosInfo = await DeviceUtils.requiresDeviceInfo().macOsInfo;

    return {
      'platform': Platform.operatingSystem,
      'brand': 'Apple',
      'model': macosInfo.model,
      'name': macosInfo.modelName,
      'systemName': macosInfo.systemGUID,
      'systemVersion': macosInfo.majorVersion,
      'device': macosInfo.modelName,
      'product': macosInfo.modelName,
      'hardware': macosInfo.hostName,
      'manufacturer': "Apple",
      'version': {
        'sdkInt': macosInfo.majorVersion,
        'release': macosInfo.osRelease,
      },
      'utsname': {
        'sysname': macosInfo.computerName,
        'nodename': "",
        'release': macosInfo.osRelease,
        'version': macosInfo.majorVersion,
        'machine': macosInfo.model,
      },
      'isPhysicalDevice': "true",
      'identifierForVendor': "",
    };
  }


  static void registerHarmonyDeviceInfoHook(Future<Map<String, dynamic>> method) async {
    _harmonyDeviceInfoHook = method;
  }

  // 获取鸿蒙设备信息
  static Future<Map<String, dynamic>> _getHarmonyDeviceInfo() async {
    return await _harmonyDeviceInfoHook ?? {};
  }

  // 基础设备信息（备用）
  static Map<String, dynamic> _getBasicDeviceInfo() {
    var versionInfo = {
      'version': Platform.operatingSystemVersion,
      'sdkInt': Platform.version.toString(),
      'release': "",
      'codename': "",
      'baseOS': Platform.operatingSystem,
    };
    return {
      'platform': Platform.operatingSystem,
      'version': versionInfo,
      'localHostname': Platform.localHostname,
      'brand': '',
      'model': "",
      'name': "",
      'systemName': "",
      'systemVersion': "",
      'device': "",
      'product': "",
      'hardware': "",
      'manufacturer': "",
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
      var connectivityResult = await DeviceUtils.requiresConnectivity().checkConnectivity();

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
    return DeviceUtils.requiresConnectivity().onConnectivityChanged.map((result) {
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

  // // 获取设备唯一标识
  // static Future<String> getDeviceId() async {
  //   try {
  //     if (Platform.isAndroid) {
  //       AndroidDeviceInfo androidInfo = await requiresDeviceInfo().androidInfo;
  //       return androidInfo.id;
  //     } else if (Platform.isIOS) {
  //       IosDeviceInfo iosInfo = await requiresDeviceInfo().iosInfo;
  //       return iosInfo.identifierForVendor ?? 'unknown_ios_id';
  //     } else {
  //       return 'unknown_platform';
  //     }
  //   } catch (e) {
  //     return 'error_getting_device_id';
  //   }
  // }
}