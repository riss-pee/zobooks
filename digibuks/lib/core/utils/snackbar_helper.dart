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
    final ctx = Get.overlayContext;
    // If overlay context not available, retry later.
    // Some GetX versions report overlayContext as non-nullable; keep the
    // defensive null-check for safety across versions.
    // ignore: unnecessary_null_comparison
    if (ctx == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showAttempt());
      return;
    }

    // If overlay isn't ready yet, retry later.
    if (Overlay.of(ctx) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showAttempt());
      return;
    }

    // Safe to show snackbar now
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: duration,
    );
  }

  showAttempt();
}
