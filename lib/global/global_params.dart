import 'dart:io';

import 'package:module_base/utils/device/device_info_helper.dart';
import 'package:module_base/utils/device/device_utils.dart';
import 'package:module_base/utils/user/app_user_helper.dart';

/// 全局参数
class GlobalReportParams {
  GlobalReportParams._();

  static const String APP_INFO = "app_info";

  static Map<String, dynamic> _commonProperties = {};

  static addCommonParam(String key, dynamic value) {
    _commonProperties[key] = value;
  }

  static Map<String, dynamic> getCommonParams() {
    return _commonProperties;
  }

  /// 获取 app 信息
  static Future<Map<String, dynamic>> getAppInfoMap() async {
    final appInfo = await DeviceService.getAppInfo();

    final appInfMap = <String, dynamic >{
      'app_name': appInfo?['appName'],
      'package_name': appInfo?['packageName'],
      'version_name': appInfo?['fullVersion'],
      'version_code': appInfo?['buildNumber'],
    };
    final commonProps = GlobalReportParams.getCommonParams();
    if (commonProps[APP_INFO] is Map) {
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
    var deviceType = await DeviceUtils.getDeviceType();

    var infoMap = await DeviceService.getDeviceInfo();
    String brand = infoMap['brand'] ?? "";
    String product = infoMap['product'] ?? "";
    String model = infoMap['model'] ?? "";
    String deviceName = infoMap['device'] ?? "";

    String hardware = infoMap['hardware'] ?? "";
    String manufacturer = infoMap['manufacturer'] ?? "";

    String sdkInt = "";
    String baseOS = "";
    String osVersion = "";

    var versionInfo = infoMap['version'];
    if (versionInfo != null) {
      sdkInt = versionInfo['sdkInt']?.toString() ?? "";
      baseOS = versionInfo['baseOS'] ?? "";
      // Android 用 'release'，iOS 用顶层的 'systemVersion'
      osVersion = versionInfo['release'] ?? infoMap['systemVersion'] ?? "";
    } else {
      // iOS 的 systemVersion 在顶层
      osVersion = infoMap['systemVersion'] ?? "";
    }

    final deviceInfo = <String, dynamic>{
      'os': Platform.operatingSystem,
      'os_version': osVersion,
      'device_name': deviceName,
      'brand': brand,
      'model': model,
      'product': product,
      'hardware': hardware,
      'manufacturer': manufacturer,
      'sdkInt': sdkInt,
      'base_OS': baseOS,
      'device_type': deviceType,
    };
    final commonProps = GlobalReportParams.getCommonParams();
    if (commonProps['device_info'] is Map) {
      deviceInfo.addAll(Map<String, dynamic>.from(commonProps['device_info']));
    }

    return deviceInfo;
  }

  /// 获取网络信息
  static Future<Map<String, dynamic>> getNetWorkInfoMap() async {
    var networkType = await DeviceUtils.getCurrentNetworkType();
    return {
      'network_type': networkType,
    };
  }

}