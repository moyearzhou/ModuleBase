import 'dart:io';

import 'package:module_base/utils/device/device_info_helper.dart';
import 'package:module_base/utils/device/device_utils.dart';
import 'package:module_base/utils/user/app_user_helper.dart';

/// 全局参数
class GlobalReportParams {
  GlobalReportParams._();

  static const String appInfoKey = "app_info";

  static final Map<String, dynamic> _commonProperties = {};

  static addCommonParam(String key, dynamic value) {
    _commonProperties[key] = value;
  }

  static Map<String, dynamic> getCommonParams() {
    return _commonProperties;
  }

  /// 获取 app 信息
  static Future<Map<String, dynamic>> getAppInfoMap() async {
    final appInfo = await DeviceService.getAppInfo();

    final appInfMap = <String, dynamic>{
      'app_name': appInfo['appName'],
      'package_name': appInfo['packageName'],
      'version_name': appInfo['fullVersion'],
      'version_code': appInfo['buildNumber'],
    };
    final commonProps = GlobalReportParams.getCommonParams();
    if (commonProps[appInfoKey] is Map) {
      appInfMap.addAll(Map<String, dynamic>.from(commonProps['app_info']));
    }
    return appInfMap;
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>> getUserInfoMap() async {
    final uuid = await AppUserHelper.getUUID();
    final userInfo = <String, dynamic>{
      'unique_id': uuid,
    };
    final commonProps = GlobalReportParams.getCommonParams();
    if (commonProps['user_info'] is Map) {
      userInfo.addAll(Map<String, dynamic>.from(commonProps['user_info']));
    }
    return userInfo;
  }

  /// 获取设备信息
  static Future<Map<String, dynamic>> getDeviceInfoMap() async {
    final deviceType = await DeviceUtils.getDeviceType();
    final infoMap = await DeviceService.getDeviceInfo();
    final deviceInfo = buildDeviceInfoMap(
      infoMap: infoMap,
      deviceType: deviceType,
      operatingSystem: Platform.operatingSystem,
    );
    final commonProps = GlobalReportParams.getCommonParams();
    if (commonProps['device_info'] is Map) {
      deviceInfo.addAll(Map<String, dynamic>.from(commonProps['device_info']));
    }

    return deviceInfo;
  }

  static Map<String, dynamic> buildDeviceInfoMap({
    required Map<String, dynamic> infoMap,
    required String deviceType,
    required String operatingSystem,
  }) {
    final versionInfo = _mapFrom(infoMap['version']);
    final brand = infoMap['brand']?.toString() ?? "";
    final model = infoMap['model']?.toString() ?? "";
    final product = infoMap['product']?.toString() ?? "";
    final deviceName = infoMap['device']?.toString() ?? "";
    final hardware = infoMap['hardware']?.toString() ?? "";

    final osVersion = _resolveOsVersion(
      operatingSystem: operatingSystem,
      infoMap: infoMap,
      versionInfo: versionInfo,
    );
    final sdkInt = operatingSystem == 'android'
        ? (versionInfo?['sdkInt']?.toString() ?? "")
        : "";
    final baseOS = operatingSystem == 'android'
        ? (versionInfo?['baseOS']?.toString() ?? "")
        : "";
    final manufacturer = _resolveManufacturer(
      operatingSystem: operatingSystem,
      infoMap: infoMap,
    );

    final deviceInfo = <String, dynamic>{
      'os': operatingSystem,
      'os_version': osVersion,
      'device_name': deviceName,
      'brand': brand,
      'model': model,
      'product': product,
      'hardware': _resolveHardware(
        operatingSystem: operatingSystem,
        infoMap: infoMap,
      ),
      'manufacturer': manufacturer,
      // Keep the legacy key for existing backend queries. It is Android-only;
      // iOS/macOS system versions must not be stored under sdkInt.
      'sdkInt': sdkInt,
      'base_OS': baseOS,
      'device_type': deviceType,
    };

    final kernelVersion = versionInfo?['release']?.toString();
    if (kernelVersion != null && kernelVersion.isNotEmpty) {
      deviceInfo['kernel_version'] = kernelVersion;
    }
    if (hardware.isNotEmpty) {
      deviceInfo['hardware_model'] = hardware;
    }

    return deviceInfo;
  }

  static String _resolveOsVersion({
    required String operatingSystem,
    required Map<String, dynamic> infoMap,
    required Map<String, dynamic>? versionInfo,
  }) {
    if (operatingSystem == 'ios') {
      return infoMap['systemVersion']?.toString() ??
          versionInfo?['sdkInt']?.toString() ??
          "";
    }
    if (operatingSystem == 'macos') {
      return versionInfo?['release']?.toString() ??
          infoMap['systemVersion']?.toString() ??
          "";
    }
    return versionInfo?['release']?.toString() ??
        infoMap['systemVersion']?.toString() ??
        "";
  }

  static String _resolveManufacturer({
    required String operatingSystem,
    required Map<String, dynamic> infoMap,
  }) {
    if (operatingSystem == 'ios' || operatingSystem == 'macos') {
      return 'Apple';
    }
    return infoMap['manufacturer']?.toString() ?? "";
  }

  static String _resolveHardware({
    required String operatingSystem,
    required Map<String, dynamic> infoMap,
  }) {
    if (operatingSystem == 'macos') {
      return infoMap['model']?.toString() ??
          infoMap['hardware']?.toString() ??
          "";
    }
    return infoMap['hardware']?.toString() ?? "";
  }

  /// 获取网络信息
  static Future<Map<String, dynamic>> getNetWorkInfoMap() async {
    var networkType = await DeviceUtils.getCurrentNetworkType();
    return {
      'network_type': networkType,
    };
  }

  static Map<String, dynamic>? _mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
