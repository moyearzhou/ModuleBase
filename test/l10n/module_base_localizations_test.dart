import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_base/ext/datetime.dart';
import 'package:module_base/generated/l10n/l10n.dart' as legacy;
import 'package:module_base/generated/l10n/l10n_en.dart' as legacy_en;
import 'package:module_base/main.dart';
import 'package:module_base/res/l10n.dart';
import 'package:module_base/utils/view/btn_picker_utils.dart';
import 'package:module_base/view/dialog/neat_dialog.dart';
import 'package:module_base/view/input.dart';
import 'package:module_base/view/toolbar/neat_toolbar.dart';
import 'package:module_base/view/widget/btn/btn.dart';
import 'package:module_base/view/widget/btn/count_down_btn.dart';
import 'package:neatly/neatly.dart';

void main() {
  tearDown(() => AppLocal.setLocale(const Locale('en')));

  test('catalogs cover the same keys and legacy imports remain usable', () {
    Map<String, dynamic> catalog(String language) =>
        jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync());
    final en = catalog('en'), zh = catalog('zh');
    expect(en.keys.where((key) => !key.startsWith('@')).toSet(),
        zh.keys.where((key) => !key.startsWith('@')).toSet());
    expect(legacy.AppLocalizations.delegate, same(AppLocal.delegate));
    expect(legacy_en.AppLocalizationsEn().cancel, 'Cancel');
    expect(legacy.lookupAppLocalizations(const Locale('zh')).cancel, '取消');
    expect(AppLocal.resolve(const Locale('zh', 'TW')).cancel, '取消');
    expect(AppLocal.resolve(const Locale('fr')).cancel, 'Cancel');
  });

  for (final sheet in [false, true]) {
    testWidgets(
        '${sheet ? 'sheet' : 'dialog'} defaults switch while open without losing edits',
        (tester) async {
      final locale = ValueNotifier(const Locale('en'));
      final input = TextEditingController();
      addTearDown(locale.dispose);
      addTearDown(input.dispose);
      await tester.pumpWidget(ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (_, value, __) => _host(
            value,
            Builder(
                builder: (context) => TextButton(
                    onPressed: () {
                      final field = TextField(controller: input);
                      if (sheet) {
                        BrnPickerUtils.show(context, contentWidget: field);
                      } else {
                        NeatDialogManager.showConfirmDialog(context,
                            messageWidget: field);
                      }
                    },
                    child: const Text('open')))),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text(sheet ? 'OK' : 'Confirm'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'edited content');
      final fieldState = tester.state(find.byType(EditableText));
      locale.value = const Locale('zh');
      await tester.pumpAndSettle();
      expect(find.text('取消'), findsOneWidget);
      expect(find.text(sheet ? '确定' : '确认'), findsOneWidget);
      expect(input.text, 'edited content');
      expect(tester.state(find.byType(EditableText)), same(fieldState));
      expect(
          NeatlyTheme.of(tester.element(find.byType(TextField)))
              .resources
              .cancelLabel,
          '取消');
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '${sheet ? 'sheet' : 'dialog'} preserves explicit labels including empty text',
        (tester) async {
      await tester.pumpWidget(_host(
          const Locale('zh'),
          Builder(
              builder: (context) => TextButton(
                  onPressed: () {
                    if (sheet) {
                      BrnPickerUtils.show(context,
                          contentWidget: const Text('content'),
                          cancel: '',
                          confirm: 'Custom');
                    } else {
                      NeatDialogManager.showConfirmDialog(context,
                          cancel: '', confirm: 'Custom');
                    }
                  },
                  child: const Text('open')))));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('取消'), findsNothing);
      expect(find.text(''), findsWidgets);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
      'host locale fallback is reactive without the ModuleBase delegate',
      (tester) async {
    final locale = ValueNotifier(const Locale('en'));
    addTearDown(locale.dispose);
    await tester.pumpWidget(ValueListenableBuilder<Locale>(
      valueListenable: locale,
      builder: (_, value, __) => _host(value,
          Builder(builder: (context) => Text(AppLocal.of(context).yesterday)),
          moduleDelegate: false),
    ));
    expect(find.text('Yesterday'), findsOneWidget);
    expect(legacy.AppLocalizations.of(tester.element(find.text('Yesterday'))),
        isNull);
    locale.value = const Locale('zh');
    await tester.pumpAndSettle();
    expect(find.text('昨天'), findsOneWidget);
    expect(l10n.localeName, 'en');
  });

  testWidgets('nested hosts do not overwrite each other or Neatly resources',
      (tester) async {
    await tester.pumpWidget(_host(
        const Locale('en'),
        Column(children: [
          Builder(builder: (context) => Text(AppLocal.of(context).cancel)),
          Expanded(
              child: _host(
                  const Locale('zh'),
                  Builder(
                      builder: (context) => Column(children: [
                            Text(AppLocal.of(context).cancel),
                            Text(NeatlyTheme.of(context).resources.cancelLabel),
                          ])))),
        ])));
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('取消'), findsNWidgets(2));
    expect(l10n.localeName, 'en');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'default buttons translate during build while literal text stays unchanged',
      (tester) async {
    final locale = ValueNotifier(const Locale('en'));
    addTearDown(locale.dispose);
    final actions =
        Row(children: [Btn.ok(), Btn.cancel(), const Btn.text(text: 'cancel')]);
    await tester.pumpWidget(ValueListenableBuilder<Locale>(
      valueListenable: locale,
      builder: (_, value, child) => _host(value, child!),
      child: actions,
    ));
    expect(find.text('OK'), findsOneWidget);
    locale.value = const Locale('zh');
    await tester.pumpAndSettle();
    expect(find.text('确定'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('cancel'), findsOneWidget);
  });

  testWidgets('countdown and password tooltips follow locale', (tester) async {
    await tester.pumpWidget(_host(
        const Locale('zh'),
        Column(children: [
          CountDownBtn(seconds: 1, onTap: () {}),
          const Input(obscureText: true, suggestion: false, noWrap: true),
        ])));
    expect(find.text('1 秒'), findsOneWidget);
    expect(find.byTooltip('显示密码'), findsOneWidget);
    await tester.tap(find.byTooltip('显示密码'));
    await tester.pump();
    expect(find.byTooltip('隐藏密码'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('确定'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  test('relative dates use explicit locale and compare the full calendar date',
      () {
    final yesterday = DateTime(2026, 10, 31, 8, 5);
    final now = DateTime(2026, 11, 1);
    expect(yesterday.simple(nowOverride: now, locale: const Locale('zh')),
        '昨天 08:05');
    expect(yesterday.simple(nowOverride: now, locale: const Locale('en')),
        'Yesterday 08:05');
    expect(
        DateTime(2026, 10, 16).simple(
            nowOverride: DateTime(2026, 11, 17), locale: const Locale('zh')),
        '10-16 00:00');
    expect(
        DateTime(2025, 12, 31, 9).simple(
            nowOverride: DateTime(2026, 1, 1), locale: const Locale('en')),
        'Yesterday 09:00');
    AppLocal.setLocale(const Locale('zh'));
    expect(yesterday.simple(nowOverride: now), '昨天 08:05');
  });

  testWidgets('relative date in a widget follows host locale', (tester) async {
    await tester.pumpWidget(_host(
        const Locale('zh'),
        Builder(
            builder: (context) => Text(DateTime(2026, 11, 16, 9).simple(
                context: context, nowOverride: DateTime(2026, 11, 17))))));
    expect(find.text('昨天 09:00'), findsOneWidget);
  });

  testWidgets('toolbar refreshes the title supplied by its host',
      (tester) async {
    for (final language in ['en', 'zh']) {
      await tester.pumpWidget(_host(
          Locale(language),
          Builder(
              builder: (context) => Scaffold(
                  appBar: NeatToolbar(title: AppLocal.of(context).settings)))));
      expect(find.text(language == 'en' ? 'Settings' : '设置'), findsOneWidget);
    }
  });

  testWidgets(
      'default buttons retain their confirmation and cancellation results',
      (tester) async {
    bool? result;
    await tester.pumpWidget(_host(
        const Locale('en'),
        Builder(
            builder: (context) => TextButton(
                  child: const Text('open'),
                  onPressed: () async {
                    result = await showDialog<bool>(
                        context: context,
                        builder: (_) =>
                            AlertDialog(actions: [Btn.cancel(), Btn.ok()]));
                  },
                ))));
    for (final label in ['OK', 'Cancel']) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(result, label == 'OK');
    }
  });

  testWidgets('demo switches language and keeps the counter state',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('ModuleBase localization'), findsOneWidget);
    await tester.tap(find.byTooltip('Increment'));
    await tester.pump();
    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();
    expect(find.text('ModuleBase 国际化'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Locale locale, Widget child, {bool moduleDelegate = true}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocal.supportedLocales,
      localizationsDelegates: [
        if (moduleDelegate) AppLocal.delegate,
        NeatlyLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(body: child),
    );
