import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

class ItemMenu {
  const ItemMenu(this.key, this.title, this.icon, this.tap);

  final String key;
  final String title;
  final IconData icon;
  final VoidCallback? tap;
}

class AppbarIcon {
  const AppbarIcon(this.icon, this.tap);

  final IconData icon;
  final VoidCallback? tap;
}

/// Legacy wrapper backed by Neatly's app bar instead of Bruno.
PreferredSizeWidget neatAppBar(
  String title,
  AppbarIcon? leadingIcon,
  List<ItemMenu>? moreOptionsMenus,
  Function moreOptionTap,
) {
  final actions = moreOptionsMenus == null || moreOptionsMenus.isEmpty
      ? null
      : <Widget>[
          PopupMenuButton<String>(
            onSelected: (key) {
              for (final menu in moreOptionsMenus) {
                if (menu.key == key) menu.tap?.call();
              }
            },
            itemBuilder: (context) => moreOptionsMenus
                .map(
                  (menu) => PopupMenuItem<String>(
                    value: menu.key,
                    child: Row(
                      children: [
                        Icon(menu.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(menu.title),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ];
  return NeatlyAppBar(
    title: title,
    automaticallyImplyLeading: leadingIcon == null,
    leading: leadingIcon == null
        ? null
        : IconButton(onPressed: leadingIcon.tap, icon: Icon(leadingIcon.icon)),
    actions: actions,
  );
}

PreferredSizeWidget simpleAppBar({
  BuildContext? context,
  String title = '',
  dynamic actions,
}) => NeatlyAppBar(
  title: title,
  actions: actions is List<Widget> ? actions : null,
);
