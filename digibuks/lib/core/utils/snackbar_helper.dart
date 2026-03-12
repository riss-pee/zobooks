import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Safely show a snackbar using GetX. If the overlay/context is not
/// available yet (e.g., during early initialization), schedule the
/// snackbar to be shown after the current frame instead of throwing.
void showSnackSafe(
  String title,
  String message, {
  SnackPosition? snackPosition,
  Color? backgroundColor,
  Color? colorText,
  Duration? duration,
}) {
  void showAttempt() {
    try {
      final ctx = Get.overlayContext;
      // ignore: unnecessary_null_comparison
      if (ctx == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => showAttempt());
        return;
      }

      // Try to access the overlay — if it throws, retry later
      try {
        Overlay.of(ctx);
      } catch (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => showAttempt());
        return;
      }

      Get.snackbar(
        title,
        message,
        snackPosition: snackPosition ?? SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration,
      );
    } catch (_) {
      // Silently fail if we still can't show — avoid crashing the app
    }
  }

  showAttempt();
}
