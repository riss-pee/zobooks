import 'package:flutter/material.dart';
// removed unused import: app_theme

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!, style: Theme.of(context).textTheme.titleLarge) : null,
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      centerTitle: false,
      actions: actions,
    );
  }
}
