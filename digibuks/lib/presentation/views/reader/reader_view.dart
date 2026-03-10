import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reader_controller.dart';
// removed unused import: book_model
import '../../../data/models/sample_content.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
// PDF and EPUB libraries imported but using placeholder implementation for demo
// import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';
// import 'package:epubx/epubx.dart' as epub;

import '../../widgets/glass_container.dart';

class ReaderView extends StatelessWidget {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReaderController());

    if (controller.book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reader')),
        body: const Center(child: Text('Book not found')),
      );
    }

    return Obx(
      () => Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: controller.isDarkMode
                  ? [
                      const Color(0xFF1A1C1E),
                      const Color(0xFF111417),
                      const Color(0xFF0D0F11),
                    ]
                  : [
                      const Color(0xFFF5F5F5),
                      const Color(0xFFEEEEEE),
                      const Color(0xFFE0E0E0),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Reader Content
              _buildReaderContent(context, controller),

              // Top App Bar - Animated
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: controller.isFullScreen ? -100 : 25,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: controller.isFullScreen ? 0.0 : 1.0,
                  child: _buildAppBar(context, controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ReaderController controller) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      blur: 40,
      opacity: controller.isDarkMode ? 0.25 : 0.15,
      borderRadius: 20,
      color: controller.isDarkMode ? Colors.black : Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color:
                    controller.isDarkMode ? Colors.white : AppTheme.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.book!.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: controller.isDarkMode
                            ? Colors.white
                            : AppTheme.textDark,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.totalPages > 0)
                  Text(
                    'Page ${controller.currentPage + 1} of ${controller.totalPages}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: controller.isDarkMode
                              ? Colors.white70
                              : AppTheme.textMuted,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color:
                    controller.isDarkMode ? Colors.white : AppTheme.textDark),
            onPressed: () => _showSettingsDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(
      BuildContext context, ReaderController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: controller.book!.fileType == AppConstants.fileTypePDF
          ? _buildPDFReader(context, controller)
          : _buildEPUBReader(context, controller),
    );
  }

  Widget _buildPDFReader(BuildContext context, ReaderController controller) {
    final content = SampleContent.getSampleContent(controller.book?.id ?? '');

    // Determine colors based on theme type
    Color bgColor;
    Color textColor;
    Color mutedTextColor;

    switch (controller.themeType) {
      case 'sepia':
        bgColor = const Color(0xFFF4ECD8);
        textColor = const Color(0xFF5B4636);
        mutedTextColor = const Color(0xFF5B4636).withOpacity(0.7);
        break;
      case 'dark':
        bgColor = const Color(0xFF1E1E1E);
        textColor = const Color(0xFFE2E2E6);
        mutedTextColor = const Color(0xFFE2E2E6).withOpacity(0.7);
        break;
      default: // light
        bgColor = Colors.white;
        textColor = const Color(0xFF1A1C1E);
        mutedTextColor = const Color(0xFF1A1C1E).withOpacity(0.6);
    }

    return GlassContainer(
      blur: 5,
      opacity: controller.isDarkMode ? 0.08 : 0.05,
      borderRadius: 24,
      color: bgColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(controller.fontSize + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.book?.title ?? 'Book',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: controller.fontFamily,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'By ${controller.book?.authorName ?? "Unknown Author"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedTextColor,
                    fontStyle: FontStyle.italic,
                    fontFamily: controller.fontFamily,
                  ),
            ),
            Divider(height: 48, color: textColor.withOpacity(0.1)),
            Text(
              content,
              style: TextStyle(
                fontSize: controller.fontSize,
                height: controller.lineHeight,
                color: textColor.withOpacity(0.9),
                fontFamily: controller.fontFamily,
              ),
              textAlign: controller.textAlign == 'justify'
                  ? TextAlign.justify
                  : TextAlign.left,
            ),
            const SizedBox(height: 40),
            // Progress
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: controller.readingProgress,
                    minHeight: 6,
                    backgroundColor: textColor.withOpacity(0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Progress: ${controller.getProgressText()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedTextColor,
                        fontFamily: 'Outfit',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: controller.currentPage > 0
                      ? () => controller.previousPage()
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(foregroundColor: textColor),
                ),
                TextButton.icon(
                  onPressed: controller.currentPage < controller.totalPages - 1
                      ? () => controller.nextPage()
                      : null,
                  icon: const Text('Next'),
                  label: const Icon(Icons.chevron_right_rounded),
                  style: TextButton.styleFrom(foregroundColor: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEPUBReader(BuildContext context, ReaderController controller) {
    final content =
        SampleContent.getEPUBSampleContent(controller.book?.id ?? '');
    final textColor = controller.isDarkMode ? Colors.white : AppTheme.textDark;
    final mutedTextColor =
        controller.isDarkMode ? Colors.white70 : AppTheme.textMuted;

    return GlassContainer(
      blur: 5,
      opacity: controller.isDarkMode ? 0.08 : 0.05,
      borderRadius: 24,
      color: controller.isDarkMode ? Colors.black12 : Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(controller.fontSize + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.book?.title ?? 'Book',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Outfit',
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'By ${controller.book?.authorName ?? "Unknown Author"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedTextColor,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Outfit',
                  ),
            ),
            Divider(height: 48, color: textColor.withOpacity(0.1)),
            Text(
              content,
              style: TextStyle(
                fontSize: controller.fontSize,
                height: controller.lineHeight,
                color: textColor.withOpacity(0.9),
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: controller.readingProgress,
                    minHeight: 6,
                    backgroundColor:
                        controller.isDarkMode ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Progress: ${controller.getProgressText()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedTextColor,
                        fontFamily: 'Outfit',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: controller.currentPage > 0
                      ? () => controller.previousPage()
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(foregroundColor: textColor),
                ),
                TextButton.icon(
                  onPressed: controller.currentPage < controller.totalPages - 1
                      ? () => controller.nextPage()
                      : null,
                  icon: const Text('Next'),
                  label: const Icon(Icons.chevron_right_rounded),
                  style: TextButton.styleFrom(foregroundColor: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, ReaderController controller) {
    Get.bottomSheet(
      Obx(() => Container(
            decoration: BoxDecoration(
              color: controller.isDarkMode
                  ? const Color(0xFF1E1E2C)
                  : const Color(0xFFF8F9FA),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 12, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: controller.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Reader Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          controller.isDarkMode ? Colors.white : Colors.black87,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions Section
                  _buildSectionTitle('ACTIONS', controller),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildActionTile(
                          icon: controller.isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          label: 'Full Screen',
                          onTap: () {
                            controller.toggleFullScreen();
                            Get.back();
                          },
                          controller: controller,
                        ),
                        const SizedBox(width: 12),
                        _buildActionTile(
                          icon: Icons.bookmarks_rounded,
                          label: 'Bookmarks',
                          onTap: () {
                            Get.back();
                            _showBookmarksDialog(context, controller);
                          },
                          controller: controller,
                        ),
                        const SizedBox(width: 12),
                        _buildActionTile(
                          icon: Icons.notes_rounded,
                          label: 'Notes',
                          onTap: () {
                            Get.back();
                            _showNotesDialog(context, controller);
                          },
                          controller: controller,
                        ),
                        const SizedBox(width: 12),
                        _buildActionTile(
                          icon: Icons.note_add_rounded,
                          label: 'Add Note',
                          onTap: () {
                            Get.back();
                            _showAddNoteDialog(context, controller);
                          },
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Themes
                  _buildSectionTitle('THEME', controller),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildThemeButton('Light', 'light', controller),
                      const SizedBox(width: 12),
                      _buildThemeButton('Sepia', 'sepia', controller),
                      const SizedBox(width: 12),
                      _buildThemeButton('Dark', 'dark', controller),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Font Size
                  _buildSectionTitle('FONT SIZE', controller),
                  _buildSlider(
                    value: controller.fontSize,
                    min: 12,
                    max: 32,
                    onChanged: (v) => controller.setFontSize(v),
                    label: '${controller.fontSize.toInt()}',
                    controller: controller,
                  ),
                  const SizedBox(height: 24),

                  // Font Family
                  _buildSectionTitle('FONT', controller),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFontButton('Outfit', controller),
                      _buildFontButton('Georgia', controller),
                      _buildFontButton('Montserrat', controller),
                      _buildFontButton('Mono', controller),
                      _buildFontButton('Open Sans', controller),
                      _buildFontButton('Inter', controller),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Text Align
                  _buildSectionTitle('TEXT ALIGN', controller),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAlignButton('Left', 'left',
                          Icons.align_horizontal_left_rounded, controller),
                      const SizedBox(width: 12),
                      _buildAlignButton('Justify', 'justify',
                          Icons.align_horizontal_right_rounded, controller),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Line Height
                  _buildSectionTitle('LINE HEIGHT', controller),
                  _buildSlider(
                    value: controller.lineHeight,
                    min: 1.0,
                    max: 2.5,
                    onChanged: (v) => controller.setLineHeight(v),
                    label: controller.lineHeight.toStringAsFixed(1),
                    controller: controller,
                  ),
                  const SizedBox(height: 24),

                  // Brightness
                  _buildSectionTitle('BRIGHTNESS', controller),
                  _buildSlider(
                    value: controller.brightness,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) => controller.setBrightness(v),
                    label: '${(controller.brightness * 100).toInt()}%',
                    controller: controller,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ReaderController controller,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: controller.isDarkMode ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: controller.isDarkMode ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: controller.isDarkMode ? Colors.white : AppTheme.textDark,
                size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: controller.isDarkMode ? Colors.white70 : Colors.black54,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ReaderController controller) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: controller.isDarkMode ? Colors.white54 : Colors.black45,
        fontFamily: 'Outfit',
      ),
    );
  }

  Widget _buildThemeButton(
      String label, String type, ReaderController controller) {
    final isSelected = controller.themeType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setThemeType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor
                : (controller.isDarkMode ? Colors.white10 : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (controller.isDarkMode ? Colors.white24 : Colors.black12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (controller.isDarkMode ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontButton(String font, ReaderController controller) {
    final isSelected = controller.fontFamily == font;
    return GestureDetector(
      onTap: () => controller.setFontFamily(font),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (controller.isDarkMode ? Colors.white10 : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (controller.isDarkMode ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Text(
          font,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (controller.isDarkMode ? Colors.white70 : Colors.black87),
            fontFamily: font == 'Mono' ? 'monospace' : font,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignButton(
      String label, String align, IconData icon, ReaderController controller) {
    final isSelected = controller.textAlign == align;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTextAlign(align),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor
                : (controller.isDarkMode ? Colors.white10 : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (controller.isDarkMode ? Colors.white24 : Colors.black12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (controller.isDarkMode
                          ? Colors.white70
                          : Colors.black87)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (controller.isDarkMode
                          ? Colors.white70
                          : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String label,
    required ReaderController controller,
  }) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => onChanged(v),
            activeColor: AppTheme.primaryColor,
            inactiveColor:
                controller.isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              color: controller.isDarkMode ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showBookmarksDialog(BuildContext context, ReaderController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          child: controller.bookmarks.isEmpty
              ? const Center(child: Text('No bookmarks yet'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.bookmarks.length,
                  itemBuilder: (context, index) {
                    final page = controller.bookmarks[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text('Page ${page + 1}'),
                      onTap: () {
                        controller.goToPage(page);
                        Navigator.pop(context);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          controller.bookmarks.remove(page);
                          Navigator.pop(context);
                          _showBookmarksDialog(context, controller);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, ReaderController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notes'),
        content: SizedBox(
          width: double.maxFinite,
          child: controller.notes.isEmpty
              ? const Center(child: Text('No notes yet'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.notes.length,
                  itemBuilder: (context, index) {
                    final entry = controller.notes.entries.elementAt(index);
                    return ListTile(
                      leading: const Icon(Icons.note),
                      title: Text('Page ${int.parse(entry.key) + 1}'),
                      subtitle: Text(entry.value),
                      onTap: () {
                        controller.goToPage(int.parse(entry.key));
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, ReaderController controller) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                controller.addNote(noteController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
