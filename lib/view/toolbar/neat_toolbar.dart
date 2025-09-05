import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NeatToolbar extends StatefulWidget implements PreferredSizeWidget  {

  final title;

  final PreferredSizeWidget? bottom;

  const NeatToolbar({super.key,
    required this.title,
    this.bottom,
  });

  @override
  State<StatefulWidget> createState() {
    return _SimpleToolbarState(title: title);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}

class _SimpleToolbarState extends State<NeatToolbar> {

  final title;

  _SimpleToolbarState({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
       title,
        style: const TextStyle(
          fontSize: 18, // 标题字体大小
          // color: Colors.white, // 标题字体颜色
          // fontWeight: FontWeight.bold, // 标题加粗
        ),),
      centerTitle: true,
      bottom: widget.bottom,
    );
  }

}