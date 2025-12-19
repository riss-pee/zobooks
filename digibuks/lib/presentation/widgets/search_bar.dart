import 'package:flutter/material.dart';
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onFilter;

  const AppSearchBar({super.key, this.controller, this.onFilter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.onSurface.withAlpha(140)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search books, authors...',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha(140)),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              color: colorScheme.primary,
              onPressed: onFilter,
            ),
          ],
        ),
      ),
    );
  }
}
