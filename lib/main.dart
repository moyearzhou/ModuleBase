import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

import 'res/l10n.dart';
import 'utils/view/btn_picker_utils.dart';
import 'view/dialog/neat_dialog.dart';

void main() => runApp(const MyApp());

/// Standalone demo: the host selects one locale for both independent delegates.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocal.supportedLocales,
      localizationsDelegates: const [
        NeatlyLocalizations.delegate,
        ...ModuleBaseLocalizations.localizationsDelegates,
      ],
      onGenerateTitle: (context) => AppLocal.of(context).demoTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Builder(
          builder: (context) => MyHomePage(
                title: AppLocal.of(context).demoHomeTitle,
                onLocaleChanged: (locale) => setState(() => _locale = locale),
              )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.onLocaleChanged});

  final String title;
  final ValueChanged<Locale>? onLocaleChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final messages = AppLocal.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.onLocaleChanged != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () =>
                        widget.onLocaleChanged!(const Locale('zh')),
                    child: const Text('中文')),
                TextButton(
                    onPressed: () =>
                        widget.onLocaleChanged!(const Locale('en')),
                    child: const Text('English')),
              ],
            ),
          Text(messages.demoCounterDescription),
          Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          TextButton(
              onPressed: () => BrnPickerUtils.show(context,
                  contentWidget: Text(messages.helloWorld)),
              child: Text(messages.openPicker)),
          TextButton(
              onPressed: () => NeatDialogManager.showConfirmDialog(context,
                  message: messages.helloWorld),
              child: Text(messages.openDialog)),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        tooltip: messages.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
