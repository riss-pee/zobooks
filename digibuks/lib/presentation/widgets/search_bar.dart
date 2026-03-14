import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onFilter;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onFilter,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            /// SEARCH ICON
            Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
            ),

            const SizedBox(width: 12),

            /// TEXT FIELD
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search books, authors...",
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(150),
                      ),
                  isDense: true,
                ),
              ),
            ),

            /// FILTER BUTTON (OPTIONAL)
            if (onFilter != null)
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: colorScheme.primary,
                ),
                tooltip: "Filters",
                onPressed: onFilter,
              ),
          ],
        ),
      ),
    );
  }
}
