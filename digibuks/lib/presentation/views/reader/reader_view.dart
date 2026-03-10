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
          child: SafeArea(
            child: Stack(
              children: [
                // Reader Content
                Column(
                  children: [
                    if (!controller.isFullScreen) const SizedBox(height: 80),
                    Expanded(
                      child: _buildReaderContent(context, controller),
                    ),
                    if (!controller.isFullScreen) const SizedBox(height: 90),
                  ],
                ),
                // Top App Bar
                if (!controller.isFullScreen)
                  Positioned(
                    top: 10,
                    left: 16,
                    right: 16,
                    child: _buildAppBar(context, controller),
                  ),
                // Bottom Controls
                if (!controller.isFullScreen)
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: _buildBottomControls(context, controller),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ReaderController controller) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      blur: 20,
      opacity: controller.isDarkMode ? 0.25 : 0.15,
      borderRadius: 20,
      color: controller.isDarkMode ? Colors.black : Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
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
                        color: controller.isDarkMode ? Colors.white : AppTheme.textDark,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.totalPages > 0)
                  Text(
                    'Page ${controller.currentPage + 1} of ${controller.totalPages}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: controller.isDarkMode ? Colors.white70 : AppTheme.textMuted,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              controller.isBookmarked(controller.currentPage)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
            onPressed: () => controller.toggleBookmark(),
          ),
          IconButton(
            icon: Icon(
              controller.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => controller.toggleDarkMode(),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fullscreen',
                child: Row(
                  children: [
                    Icon(Icons.fullscreen_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Full Screen'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bookmarks',
                child: Row(
                  children: [
                    Icon(Icons.bookmarks_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Bookmarks'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'notes',
                child: Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Notes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'fullscreen':
                  controller.toggleFullScreen();
                  break;
                case 'bookmarks':
                  _showBookmarksDialog(context, controller);
                  break;
                case 'notes':
                  _showNotesDialog(context, controller);
                  break;
                case 'settings':
                  _showSettingsDialog(context, controller);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(BuildContext context, ReaderController controller) {
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
    final textColor = controller.isDarkMode ? Colors.white : AppTheme.textDark;
    final mutedTextColor = controller.isDarkMode ? Colors.white70 : AppTheme.textMuted;
    
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
            // Progress
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: controller.readingProgress,
                    minHeight: 6,
                    backgroundColor: controller.isDarkMode ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
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
                  onPressed: controller.currentPage > 0 ? () => controller.previousPage() : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(foregroundColor: textColor),
                ),
                TextButton.icon(
                  onPressed: controller.currentPage < controller.totalPages - 1 ? () => controller.nextPage() : null,
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
    final content = SampleContent.getEPUBSampleContent(controller.book?.id ?? '');
    final textColor = controller.isDarkMode ? Colors.white : AppTheme.textDark;
    final mutedTextColor = controller.isDarkMode ? Colors.white70 : AppTheme.textMuted;
    
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
                    backgroundColor: controller.isDarkMode ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
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
                  onPressed: controller.currentPage > 0 ? () => controller.previousPage() : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(foregroundColor: textColor),
                ),
                TextButton.icon(
                  onPressed: controller.currentPage < controller.totalPages - 1 ? () => controller.nextPage() : null,
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

  Widget _buildBottomControls(BuildContext context, ReaderController controller) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      blur: 30,
      opacity: 0.1,
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlIcon(Icons.bookmark_add_rounded, 'Bookmark', () => controller.toggleBookmark()),
          _buildControlIcon(Icons.note_add_rounded, 'Note', () => _showAddNoteDialog(context, controller)),
          _buildControlIcon(Icons.text_fields_rounded, 'Text', () => _showFontSizeDialog(context, controller)),
          _buildControlIcon(Icons.brightness_medium_rounded, 'Brightness', () => _showBrightnessDialog(context, controller)),
          _buildControlIcon(Icons.settings_rounded, 'Settings', () => _showSettingsDialog(context, controller)),
        ],
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 22),
          onPressed: onTap,
          tooltip: tooltip,
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context, ReaderController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reader Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Font Size
              ListTile(
                leading: const Icon(Icons.format_size),
                title: Text('Font Size: ${controller.fontSize.toInt()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        controller.setFontSize(controller.fontSize - 1);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        controller.setFontSize(controller.fontSize + 1);
                      },
                    ),
                  ],
                ),
              ),
              // Line Height
              ListTile(
                leading: const Icon(Icons.format_line_spacing),
                title: Text('Line Height: ${controller.lineHeight.toStringAsFixed(1)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        controller.setLineHeight(controller.lineHeight - 0.1);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        controller.setLineHeight(controller.lineHeight + 0.1);
                      },
                    ),
                  ],
                ),
              ),
              // Dark Mode
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: controller.isDarkMode,
                onChanged: (value) => controller.toggleDarkMode(),
              ),
            ],
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

  void _showFontSizeDialog(BuildContext context, ReaderController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${controller.fontSize.toInt()}'),
              Slider(
                value: controller.fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: controller.fontSize.toInt().toString(),
                onChanged: (value) {
                  controller.setFontSize(value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBrightnessDialog(BuildContext context, ReaderController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brightness'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(controller.brightness * 100).toInt()}%'),
              Slider(
                value: controller.brightness,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(controller.brightness * 100).toInt()}%',
                onChanged: (value) {
                  controller.setBrightness(value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
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
