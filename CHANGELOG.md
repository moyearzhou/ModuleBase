## 1.1.0 — 2026-11-18

* 使用 ARB + Flutter gen-l10n 生成独立的 ModuleBaseLocalizations，保留旧 AppLocalizations 导入和无 context 语言入口兼容。
* 通用按钮、确认弹窗、选择面板、倒计时与密码提示跟随宿主语言，显式文案及编辑内容保持不变。
* 日期简写支持宿主 context 或显式 locale，修正跨月同日号被误判为昨天的问题。
* 演示页面支持中英文切换，工具栏随宿主更新标题；宿主使用本次 hosted 版本。

## 1.0.4 - 2026-11-16

* Allow device_info_plus 11.x and 12.x so hosted PDF Viewer and ModuleLibrary can resolve together.
* Preserve ModuleBase runtime source and compatibility with existing 11.x hosts.

## 1.0.3 - 2026-11-16

* 首次发布到私有 pub：`https://pub.zotpaper.cn`。
* Neatly 改用私有 hosted `^0.0.5`，WebDAV fork 改用私有 hosted `^1.2.3`。
* 沿用 `v-0.2.3` 的业务行为与资源，补齐包许可、接入文档和发布文件范围。
* 补齐 SDK 上限，清理未使用代码与冗余空判断，使发布分析无错误和警告。
* 包版本独立递增，Git tag 使用 `v-1.0.3`；旧产品版本 tag 保留。

## v-0.2.3 - 2026-11-15

* 通用弹窗和底部选择面板实时跟随根主题的显示密度与窗口布局。
* 切换密度或窗口断点时保留输入状态、确认操作及局部主题配色。
* 将 Neatly 依赖固定到 `0.0.4`，并更新依赖锁文件。

### 升级说明

此 tag 固定 ZotPaper 0.2.3 使用的基础模块，沿用本仓库的 `v-<产品版本>` 命名；包内版本保持 `1.0.2+3`。

Neatly 0.0.4 包含标签 API 等不兼容调整，直接使用 Neatly 的调用方请参考其升级说明：https://github.com/ZotPaper/Neatly/releases/tag/0.0.4 。
