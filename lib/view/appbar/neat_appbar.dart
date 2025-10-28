import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import '../../theme/my_theme.dart';

class ItemMenu {
  final String key;
  final String title;
  final IconData icon;
  final Function? tap;
  ItemMenu(this.key, this.title, this.icon, this.tap);
}

class AppbarIcon {
  final IconData icon;
  final Function? tap;
  final color = AppThemes.textMain;

  AppbarIcon(this.icon, this.tap);
}

PreferredSizeWidget neatAppBar(
  String title,
  AppbarIcon? leadingIcon,
  List<ItemMenu>? moreOptionsMenus,
  Function moreOptionTap) {
  return AppBar(
    leading: leadingIcon != null ? IconButton(
        onPressed: () {
          leadingIcon.tap?.call();
        },
        icon: Icon(leadingIcon.icon, color: leadingIcon.color,)) : null,
    automaticallyImplyLeading: leadingIcon != null,
    toolbarHeight: 46,
    backgroundColor: AppThemes.bgColor,
    title: Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 16, color: AppThemes.textMain),
      ),
    ),

    actionsIconTheme: IconThemeData(color: AppThemes.textMain),
    actions: [
      PopupMenuButton<String>(
        color: AppThemes.bgColor,
        // splashRadius: 20,
        shadowColor: const Color(0x88FFFFFF),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        onSelected: (String result) {
          // todo 根据id
          for (var menu in moreOptionsMenus!) {
            if (menu.key == result) {
              menu.tap!();
            }
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          ...moreOptionsMenus!.map((menu) {
            return PopupMenuItem<String>(
              value: menu.key,
              child: Text(menu.title, style: TextStyle(color: AppThemes.textMain)),
            );
          })
        ],
      ),
    ],
  );
}


PreferredSizeWidget simpleAppBar({
  String title = "",
  dynamic actions,
}) {
  return BrnAppBar(
    automaticallyImplyLeading: true,
    leading: BrnBackLeading(
      child: Icon(Icons.arrow_back_ios_new_outlined, size: 20, color: AppThemes.textMain,),
    ),
    title: Text(
      title,
      style: TextStyle(fontSize: 16, color: AppThemes.textMain),
    ),
    iconTheme: IconThemeData(
        color: AppThemes.textMain,
    ),
    actions: actions,
  );
}



