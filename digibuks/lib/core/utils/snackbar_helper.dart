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
  void _show() {
    try {
      final ctx = Get.overlayContext;
      // If there's no overlay context or no overlay ancestor, postpone showing
      // the snackbar until after the next frame when an overlay may be available.
      if (ctx == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _show());
        return;
      }

      try {
        // Try to access Overlay; if this throws or returns null, schedule for later
        if (Overlay.of(ctx) == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _show());
          return;
        }
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _show());
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
    } catch (e) {
      // Swallow errors to avoid app crash when overlay isn't available.
      debugPrint('showSnackSafe failed: $e');
    }
  }

  _show();
}
