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
