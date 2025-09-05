import 'dart:async';
import 'package:flutter/material.dart';
import 'package:module_base/ext/obj.dart';
import 'package:module_base/ext/widget.dart';
import 'package:module_base/view/val_builder.dart';

import '../utils/store/iface.dart';
import 'fade_in.dart';
import 'loading.dart';

class StoreSwitch extends StatelessWidget {
  final StorePropDefault<bool> prop;

  /// Exec before make change, after validator.
  final FutureOr<void> Function(bool)? callback;

  /// If return false, the switch will not change.
  final FutureOr<bool> Function(bool)? validator;

  const StoreSwitch({
    super.key,
    required this.prop,
    this.callback,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = false.vn;
    // Only show [FadeIn] when previous state is busy.
    var lastIsBusy = false;

    return ValBuilder(
      listenable: isBusy,
      builder: (busy) {
        return ValBuilder(
          listenable: prop.listenable(),
          builder: (value) {
            if (busy) {
              lastIsBusy = true;
              return SizedLoading.medium.paddingOnly(right: 17);
            }

            final switcher = Switch(
              value: value,
              onChanged: (value) async {
                final valid = await validator?.call(value) ?? true;
                if (!valid) return;
                isBusy.value = true;
                await callback?.call(value);
                isBusy.value = false;
                prop.set(value);
              },
            );

            if (lastIsBusy) {
              final ret = FadeIn(child: switcher);
              lastIsBusy = false;
              return ret;
            }
            return switcher;
          },
        );
      },
    );
  }
}
