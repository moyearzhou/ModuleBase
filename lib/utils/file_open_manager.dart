import 'package:module_base/utils/device/device_utils.dart';
import 'package:open_filex/open_filex.dart';

class FileOpenManager {

  static Future<OpenRes> Function(String url)? _harmonFileOpener;

  static void registerHarmonyFileOpener(Future<OpenRes> Function(String url)? launcher) {
    _harmonFileOpener = launcher;
  }

  static Future<OpenRes> openFile(String path, {
    String? type,
    Function(String)? onError,
    Function(String)? onSuccess,
  }) async {

    if (isHarmonyOS()) {
      if (_harmonFileOpener == null) {
        return OpenRes(type: ResultEnum.noAppToOpen, message: "no app to open");
      } else {
        var res = await _harmonFileOpener?.call(path);
        return res ?? OpenRes(type: ResultEnum.error, message: "error to open: $path");
      }

    } else {
      final result = await OpenFilex.open(
        path,
        type: "application/pdf",
      );
      return OpenRes(type: OpenRes.convertJson(result.type.index), message: result.message);
    }
    // return OpenRes(type: ResultEnum.error, message: "error to open: $path");
  }
}

/// Result status and reason of error if platform returns an error
enum ResultEnum {
  done,
  fileNotFound,
  noAppToOpen,
  permissionDenied,
  error,
}


class OpenRes {
  ResultEnum type;
  String message;

  OpenRes({this.type = ResultEnum.done, this.message = "done"});

  OpenRes.fromJson(Map<String, dynamic> json)
      : message = json['message'].toString(),
        type = convertJson(json['type'] ?? -4);

  static ResultEnum convertJson(int? jsonType) {
    switch (jsonType) {
      case -1:
        return ResultEnum.noAppToOpen;
      case -2:
        return ResultEnum.fileNotFound;
      case -3:
        return ResultEnum.permissionDenied;
      case -4:
        return ResultEnum.error;
    }
    return ResultEnum.done;
  }
}