# module_base

ZotPaper 公共基础模块，包含网络、存储、日志、主题和通用界面能力。

## 私有 pub 接入

先配置私有仓库 token（在提示中输入，不写进项目）：

```sh
dart pub token add https://pub.zotpaper.cn
```

```yaml
dependencies:
  module_base:
    hosted: https://pub.zotpaper.cn
    version: ^1.0.3
```

内部依赖 `neatly ^0.0.5`、`webdav_client ^1.2.3` 也来自同一私有源，其他公开依赖使用原 hosted 来源，无需给消费方开放这两个 Git 仓库。

`1.0.3` 沿用 `v-0.2.3` 的业务行为和资源，并清理发布分析中的未使用代码与冗余判断。包版本独立于 ZotPaper App 版本，Git tag 为 `v-1.0.3`。模块继续保留现有 Flutter module 配置。

## 验证

```sh
flutter pub get
flutter test test/screen_density/live_surfaces_test.dart
flutter pub publish --dry-run
```

发布验证使用已提交文件的干净导出和独立 hosted 消费项目，避免本地 overrides、未跟踪测试或 IDE 文件影响发布。

## 许可

本包按 [内部专有许可](LICENSE) 提供给获授权成员；第三方材料仍遵循其原有许可。

## 国际化（开发分支）

文案使用 `lib/l10n/app_en.arb`、`app_zh.arb` 和 Flutter `gen-l10n`，生成独立的 `ModuleBaseLocalizations` 类型，与宿主、Neatly 的 delegate 分离。宿主统一决定语言：

```dart
import 'package:module_base/res/l10n.dart';
import 'package:neatly/neatly.dart';

MaterialApp(
  locale: selectedLocale,
  supportedLocales: AppLocal.supportedLocales,
  localizationsDelegates: const [
    ...ModuleBaseLocalizations.localizationsDelegates,
    NeatlyLocalizations.delegate,
    // 注册宿主及其他 SDK 自己的 delegate。
  ],
  home: const HomePage(),
);
```

组件通过 `AppLocal.of(context)` 或 `context.moduleBaseL10n`（导入 `ext/l10n.dart`）读取当前宿主文案，不修改全局语言。弹窗和选择面板的默认按钮随语言实时刷新并保留输入；调用方显式传入的文字（包括空字符串）优先，调用方负责翻译标题、内容和业务选项。

旧导入路径 `generated/l10n/l10n*.dart` 及 `AppLocalizations*` 名称继续兼容。旧宿主未注册 ModuleBase delegate 时，组件按宿主 `Localizations.locale` 解析；不支持的语言回退英文，同一语言的地区变体共用语言资源。宿主支持新语言前，应先补齐各 SDK 对应 ARB 并重新生成，不能只修改宿主的 `supportedLocales`。

日期展示建议使用 `date.simple(context: context)`；无界面的格式化可以传 `locale:`。旧的 `l10n`、`AppLocal.syncSystem()` 仅作为无 context 调用的兼容入口，宿主手动切换语言时可用 `AppLocal.setLocale(selectedLocale)` 同步该兼容值；页面组件不依赖这个可变值。

```sh
flutter gen-l10n
flutter test test/l10n/module_base_localizations_test.dart test/screen_density/live_surfaces_test.dart
```

本机开发在当前测试根工程的 `pubspec_overrides.yaml` 指向本地 Neatly；宿主集成时同时 override 本地 `module_base` 和 `neatly`。本地覆盖文件和包含本机路径的 lock 变更不提交，本次不发布 Pub 包。

`lib/main.dart` 提供中英文切换、计数器、弹窗和选择面板演示；语言切换由演示宿主管理。
