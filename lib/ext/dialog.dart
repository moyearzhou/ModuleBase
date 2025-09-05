import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../res/l10n.dart';
import '../utils/logger.dart';
import '../utils/platform/base.dart';
import '../view/loading.dart';
import '../view/widget/btn/btn.dart';

extension DialogX on BuildContext {
  Future<T?> showRoundDialog<T>({
    Widget? child,
    List<Widget>? actions,
    String? title,
    bool barrierDismiss = true,
    int? titleMaxLines,
    EdgeInsetsGeometry? actionsPadding,
    EdgeInsetsGeometry? contentPadding,
    Widget? Function(BuildContext ctx)? titleBuilder,
    Widget? Function(BuildContext ctx)? childBuilder,
    List<Widget>? Function(BuildContext ctx)? actionsBuilder,
  }) async {
    return await showDialog<T>(
      context: this,
      barrierDismissible: barrierDismiss,
      builder: (ctx) {
        final title_ = switch (titleBuilder) {
          null => title != null ? Text(title, maxLines: titleMaxLines) : null,
          _ => titleBuilder(ctx),
        };
        final child_ = childBuilder?.call(ctx) ?? child;
        final actions_ = actionsBuilder?.call(ctx) ?? actions;

        return AlertDialog(
          title: title_,
          content: child_,
          actions: actions_,
          actionsPadding: actionsPadding ?? const EdgeInsets.all(16),
          contentPadding: contentPadding,
        );
      },
    );
  }

//   /// [timeout] is the timeout of the Future [fn] (default `null`).
//   ///
//   /// If an error occurs:
//   /// - the dialog will be closed and an error dialog will be displayed
//   /// - the [onErr] function will be called (awaited)
//   /// - the return value will be `null`
//   Future<Res<T>> showLoadingDialog<T>({
//     required Future<T> Function() fn,
//     bool barrierDismiss = false,
//     FutureOr<void> Function(Object e, StackTrace s)? onErr,
//     Duration? timeout = const Duration(seconds: 30),
//   }) async {
//     showRoundDialog(
//       child: SizedLoading.medium,
//       barrierDismiss: barrierDismiss,
//     );
//
//     return Resx.tryCatch(() async {
//       final ret = switch (timeout) {
//         null => await fn(),
//         _ => await fn().timeout(timeout),
//       };
//       pop();
//       return ret;
//     }, onErr: (e, s) {
//       pop();
//       showErrDialog(e, s);
//       onErr?.call(e, s);
//     });
//   }
//
//   static final _recoredPwd = <String, String>{};
//
//   /// Show a dialog to input password.
//   ///
//   /// - [id] is the key to record the password.
//   /// - [remember] if true, the password will be recorded. Only works when [id] is not null.
//   Future<String?> showPwdDialog({
//     String? title,
//     String? label,
//     String? id,
//     bool remember = true,
//   }) async {
//     if (!mounted) return null;
//     return await showRoundDialog<String>(
//       title: title,
//       child: Input(
//         controller: TextEditingController(text: _recoredPwd[id]),
//         autoFocus: true,
//         type: TextInputType.visiblePassword,
//         obscureText: true,
//         onSubmitted: (val) {
//           pop(val);
//           if (remember && id != null) {
//             _recoredPwd[id] = val;
//           }
//         },
//         label: label ?? l10n.pwd,
//       ),
//     );
//   }
//
//   Future<List<T>?> showPickDialog<T>({
//     String? title,
//     required List<T> items,
//     String Function(T)? display,
//     bool multi = true,
//     List<T>? initial,
//     bool clearable = false,
//     List<Widget>? actions,
//     bool addOkBtn = true,
//   }) async {
//     var vals = initial ?? <T>[];
//     final btns = actions ?? <Widget>[];
//     if (multi && addOkBtn) {
//       btns.add(TextButton(onPressed: () => pop(true), child: Text(l10n.ok)));
//     }
//     final sure = await showRoundDialog<bool>(
//       title: title ?? l10n.select,
//       child: SingleChildScrollView(
//         child: Choice<T>(
//           onChanged: (value) {
//             vals = value;
//             if (!multi) pop(true);
//           },
//           multiple: multi,
//           clearable: clearable,
//           value: vals,
//           builder: (state, _) => Wrap(
//             children: List<Widget>.generate(
//               items.length,
//               (index) {
//                 final item = items[index];
//                 if (item == null) return UIs.placeholder;
//                 return ChoiceChipX<T>(
//                   label: display?.call(item) ?? item.toString(),
//                   state: state,
//                   value: item,
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//       actions: btns.isEmpty ? null : btns,
//     );
//     if (sure == true) return vals;
//     return null;
//   }
//
//   Future<T?> showPickSingleDialog<T>({
//     String? title,
//     required List<T> items,
//     String Function(T)? display,
//     T? initial,
//     bool clearable = false,
//     List<Widget>? actions,
//   }) async {
//     final vals = await showPickDialog<T>(
//       title: title,
//       items: items,
//       display: display,
//       multi: false,
//       initial: initial == null ? null : [initial],
//       actions: actions,
//     );
//     if (vals != null && vals.isNotEmpty) {
//       return vals.first;
//     }
//     return null;
//   }
//
//   Future<List<T>?> showPickWithTagDialog<T>({
//     String? title,
//     required List<T?> Function(String tag) itemsBuilder,
//     required ValueNotifier<Set<String>> tags,
//     String Function(T)? display,
//     List<T>? initial,
//     bool clearable = false,
//     bool multi = false,
//     List<Widget>? actions,
//   }) async {
//     var vals = initial ?? <T>[];
//     final tag = ''.vn;
//     final size = MediaQuery.sizeOf(this);
//     final choices = tag.listenVal(
//       (tVal) {
//         return Choice<T>(
//           onChanged: (value) => vals = value,
//           multiple: multi,
//           clearable: clearable,
//           value: vals,
//           builder: (state, _) {
//             final items = itemsBuilder(tVal);
//             return Wrap(
//               children: List<Widget>.generate(
//                 items.length,
//                 (index) {
//                   final item = items[index];
//                   if (item == null) return UIs.placeholder;
//                   return ChoiceChipX<T>(
//                     label: display?.call(item) ?? item.toString(),
//                     state: state,
//                     value: item,
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//
//     final sure = await showRoundDialog<bool>(
//       title: title,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TagSwitcher(
//             tags: tags,
//             initTag: tag.value,
//             onTagChanged: (e) => tag.value = e,
//           ),
//           const Divider(color: Color.fromARGB(30, 158, 158, 158)),
//           ConstrainedBox(
//             constraints: BoxConstraints(maxHeight: size.height * 0.5),
//             child: SingleChildScrollView(child: choices),
//           ),
//         ],
//       ),
//       actions: [
//         if (actions != null) ...actions,
//         TextButton(
//           onPressed: () => pop(true),
//           child: Text(l10n.ok),
//         ),
//       ],
//     );
//     if (sure == true && vals.isNotEmpty) {
//       return vals;
//     }
//     return null;
//   }
//
//   void showErrDialog([
//     Object? e,
//     StackTrace? s,
//     String? operation,
//   ]) {
//     showRoundDialog(
//       title: operation ?? l10n.fail,
//       child: ErrorView.es(e, s),
//       actions: [
//         TextButton(
//           onPressed: () => Pfs.copy('$e\n$s'),
//           child: Text(l10n.copy),
//         ),
//       ],
//     );
//   }
//
//   /// Show a dialog to import data from file, network or clipboard.
//   /// - [title] is the title of the dialog
//   /// - [modelDef] is the [Map] definition of the model, it will be displayed like:
//   ///   ```jsonc
//   ///   {"name": "", "age": 0}
//   ///   ```
//   Future<Uint8List?> showImportDialog({
//     required String title,
//     Map<String, dynamic>? modelDef,
//   }) async {
//     title = '$title - ${l10n.import}';
//     final from = await showRoundDialog<_ImportFrom>(
//       title: title,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Btn.tile(
//             onTap: () => pop(_ImportFrom.file),
//             text: l10n.file,
//             icon: const Icon(MingCute.file_line),
//           ),
//           Btn.tile(
//             onTap: () => pop(_ImportFrom.network),
//             text: l10n.network,
//             icon: const Icon(ZondIcons.network),
//           ),
//           Btn.tile(
//             onTap: () => pop(_ImportFrom.clipboard),
//             text: l10n.clipboard,
//             icon: const Icon(MingCute.clipboard_line),
//           ),
//           if (modelDef != null)
//             ExpandTile(
//               title: Text(l10n.example),
//               children: [
//                 SimpleMarkdown(
//                   data: '''
// ```json
// [
// ${const JsonEncoder.withIndent('\t\t').convert(modelDef)}
// ]
// ```''',
//                   selectable: true,
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//     if (from == null) return null;
//
//     switch (from) {
//       case _ImportFrom.file:
//         final file = await Pfs.pickFile();
//         if (file == null) return null;
//         return file.bytes;
//       case _ImportFrom.network:
//         final urlCtrl = TextEditingController();
//         final headersCtrl = TextEditingController();
//         await showRoundDialog(
//           title: title,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Input(
//                   icon: ZondIcons.network,
//                   label: 'Url',
//                   hint: 'https://a.com',
//                   controller: urlCtrl,
//                   maxLines: 3,
//                   minLines: 1,
//                   onSubmitted: (p0) => pop(),
//                 ),
//                 UIs.height7,
//                 Input(
//                   icon: HeroIcons.queue_list,
//                   label: 'Headers',
//                   hint: 'key1: value1\nkey2: value2',
//                   controller: headersCtrl,
//                   maxLines: 5,
//                   minLines: 2,
//                   onSubmitted: (p0) => pop(),
//                 ),
//               ],
//             ),
//           ),
//           actions: Btnx.oks,
//         );
//         final url = urlCtrl.text;
//         final headers = <String, String>{};
//         try {
//           final lines = headersCtrl.text.split('\n');
//           for (final line in lines) {
//             final parts = line.split(':');
//             if (parts.length != 2) continue;
//             headers[parts[0].trim()] = parts[1].trim();
//           }
//         } catch (e, s) {
//           Loggers.app.warning('showImportDialog parse headers', e, s);
//         }
//         if (url.isEmpty) return null;
//         final resp = await myDio.get(
//           url,
//           options: Options(
//             headers: headers.isEmpty ? null : headers,
//             responseType: ResponseType.bytes,
//           ),
//         );
//         return resp.data;
//       case _ImportFrom.clipboard:
//         final text = await Pfs.paste();
//         if (text == null) return null;
//         return Uint8List.fromList(text.codeUnits);
//       default:
//         throw Exception('Unknown import source: $from');
//     }
//   }
//
//   Future<bool?> showMigrationDialog(String tip) {
//     return showRoundDialog<bool>(
//       title: l10n.migrateCfg,
//       child: SingleChildScrollView(
//         child: SimpleMarkdown(data: '''
// ${libL10n.migrateCfgTip}:\n
// $tip'''),
//       ),
//       actions: Btnx.oks,
//     );
//   }
}

enum _ImportFrom {
  file,
  network,
  clipboard,
  ;
}
