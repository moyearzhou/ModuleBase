import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceUtils {

  /// 综合多种因素判断是否为平板
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final shortestSide = min(size.width, size.height);
    final longestSide = max(size.width, size.height);

    // 获取设备像素比
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // 计算屏幕对角线英寸大小
    final diagonalInches = sqrt(
        pow(size.width / devicePixelRatio / 160, 2) +
            pow(size.height / devicePixelRatio / 160, 2)
    );

    // 判断条件：
    // 1. 对角线大于6.5英寸 或者
    // 2. 最短边大于600逻辑像素
    return diagonalInches > 6.5 || shortestSide > 600;
  }

  static Future<bool> isTabletDevice() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final MediaQueryData mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.window);

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // 对于Android，我们可以通过androidInfo.deviceType（如果可用）来判断
      if (androidInfo.device != null) {
        // 如果deviceType不可用，则通过屏幕尺寸判断
        // 通常，如果屏幕短边大于600，则认为是平板
        return mediaQuery.size.shortestSide > 600;
      }
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // 对于iOS，我们可以检查model是否包含iPad
      return iosInfo.model?.toLowerCase().contains('ipad') ?? false;
    }
    // 对于其他平台，我们也可以使用屏幕尺寸判断
    return mediaQuery.size.shortestSide > 600;
  }

  /// 获取设备类型
  static Future<String> getDeviceType() async {
    if (Platform.isMacOS) {
      return "MacOS";
    } else if (Platform.isLinux) {
      return "Linux";
    } else if (Platform.isWindows) {
      return "Windows";
    } else if (Platform.isFuchsia) {
      return "Fuchsia";
    }

    var deviceType = "Phone";
    var isTablet = await DeviceUtils.isTabletDevice();
    if (isTablet) {
      deviceType = "Tablet";
    }

    return deviceType;
  }

  static Connectivity requiresConnectivity() {
    final Connectivity connectivity = Connectivity();
    return connectivity;
  }

  static DeviceInfoPlugin requiresDeviceInfo() {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return deviceInfo;
  }

  static String parserNetworkType(ConnectivityResult connectivityResult) {
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
  }

  /// 获取当前网络类型
  static Future<String> getCurrentNetworkType() async {
    var connectivityResult = await DeviceUtils.requiresConnectivity().checkConnectivity();
    var networkType = DeviceUtils.parserNetworkType(connectivityResult);

    return networkType;
  }
}

/// 判断是否为华为鸿蒙系统
isHarmonyOS() {
  return Platform.operatingSystem == "ohos";
}