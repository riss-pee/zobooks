import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const PrimaryButton({super.key, this.label, this.child, this.onPressed, this.fullWidth = false}) : assert(label != null || child != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = child ?? Text(label!, style: const TextStyle(fontWeight: FontWeight.w600));

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: content,
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
