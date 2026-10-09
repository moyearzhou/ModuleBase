import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_base/utils/view/btn_picker_utils.dart';
import 'package:module_base/view/dialog/neat_dialog.dart';
import 'package:neatly/neatly.dart';

void main() {
  for (final sheet in [false, true]) {
    testWidgets('${sheet ? 'sheet' : 'dialog'} keeps live metrics and input',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final density = ValueNotifier(NeatlyDensity.compact);
      final input = TextEditingController();
      addTearDown(density.dispose);
      addTearDown(input.dispose);
      const fieldKey = Key('surface-input');
      var confirmed = 0;
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => ValueListenableBuilder<NeatlyDensity>(
          valueListenable: density,
          builder: (context, value, _) {
            final width = MediaQuery.sizeOf(context).width;
            final screen = width < 600
                ? NeatlyScreenClass.phone
                : width < 1024
                    ? NeatlyScreenClass.tablet
                    : NeatlyScreenClass.desktop;
            final root = NeatlyThemeData.light(
              density: screen == NeatlyScreenClass.phone
                  ? NeatlyDensity.comfortable
                  : value,
              screenClass: screen,
            );
            return Theme(
              data: root.toMaterialTheme(),
              child: NeatlyTheme(data: root, child: child!),
            );
          },
        ),
        home: Builder(builder: (context) {
          final root = NeatlyTheme.of(context);
          return NeatlyTheme(
            data: root.copyWith(
              colors: root.colors.copyWith(primary: Colors.teal),
            ),
            child: Builder(builder: (localContext) {
              return Scaffold(
                  body: TextButton(
                child: const Text('open'),
                onPressed: () {
                  final content = TextField(key: fieldKey, controller: input);
                  if (sheet) {
                    BrnPickerUtils.show(
                      localContext,
                      contentWidget: content,
                      confirm: 'confirm',
                      onConfirm: () => confirmed++,
                    );
                  } else {
                    NeatDialogManager.showConfirmDialog(
                      localContext,
                      cancel: 'cancel',
                      confirm: 'confirm',
                      messageWidget: content,
                      onConfirm: (dialogContext) {
                        confirmed++;
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  }
                },
              ));
            }),
          );
        }),
      ));
      Future<void> check(NeatlyDensity value, NeatlyScreenClass screen) async {
        await tester.pumpAndSettle();
        final context = tester.element(find.byKey(fieldKey));
        final theme = NeatlyTheme.of(context);
        expect(theme.density, value);
        expect(theme.screenClass, screen);
        expect(theme.colors.primary, Colors.teal);
        expect(Theme.of(context).visualDensity,
            theme.toMaterialTheme().visualDensity);
        expect(input.text, 'retained input');
        expect(tester.takeException(), isNull);
      }

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(fieldKey), 'retained input');
      final state = tester.state(find.byType(EditableText));
      await check(NeatlyDensity.compact, NeatlyScreenClass.desktop);
      for (final value in [NeatlyDensity.standard, NeatlyDensity.comfortable]) {
        density.value = value;
        await check(value, NeatlyScreenClass.desktop);
      }
      density.value = NeatlyDensity.compact;
      tester.view.physicalSize = const Size(390, 800);
      await check(NeatlyDensity.comfortable, NeatlyScreenClass.phone);
      tester.view.physicalSize = const Size(800, 900);
      await check(NeatlyDensity.compact, NeatlyScreenClass.tablet);
      tester.view.physicalSize = const Size(1400, 900);
      await check(NeatlyDensity.compact, NeatlyScreenClass.desktop);
      expect(tester.state(find.byType(EditableText)), same(state));
      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();
      expect(confirmed, 1);
      expect(find.byKey(fieldKey), findsNothing);
      await tester.tap(find.text('open'));
      await check(NeatlyDensity.compact, NeatlyScreenClass.desktop);
      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    });
  }
}
