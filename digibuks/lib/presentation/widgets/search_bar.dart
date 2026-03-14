import 'package:flutter/material.dart';
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onFilter;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppSearchBar({
    super.key, 
    this.controller, 
    this.onFilter,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search books...',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(150),
                      ),
                  isDense: true,
                ),
              ),
            ),
            if (onFilter != null)
              IconButton(
                icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
                onPressed: onFilter,
                tooltip: 'Filters',
              ),
          ],
        ),
      ),
    );
  }
}
