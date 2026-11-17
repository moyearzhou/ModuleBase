import 'package:flutter/material.dart';

class NeatToolbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;

  const NeatToolbar({super.key, required this.title, this.bottom});

  @override
  State<NeatToolbar> createState() => _SimpleToolbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SimpleToolbarState extends State<NeatToolbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Read the current widget so a host locale rebuild updates the title.
      title: Text(widget.title, style: const TextStyle(fontSize: 18)),
      centerTitle: true,
      bottom: widget.bottom,
    );
  }
}
