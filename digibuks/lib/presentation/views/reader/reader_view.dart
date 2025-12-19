import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reader_controller.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/sample_content.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
// PDF and EPUB libraries imported but using placeholder implementation for demo
// import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';
// import 'package:epubx/epubx.dart' as epub;

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
        backgroundColor: controller.isDarkMode 
            ? Colors.grey[900] 
            : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              if (!controller.isFullScreen)
                _buildAppBar(context, controller),
              // Reader Content
              Expanded(
                child: _buildReaderContent(controller),
              ),
              // Bottom Controls
              if (!controller.isFullScreen)
                _buildBottomControls(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ReaderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: controller.isDarkMode 
            ? Colors.grey[850] 
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.book!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: controller.isDarkMode 
                            ? Colors.white 
                            : Colors.black,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.totalPages > 0)
                  Text(
                    'Page ${controller.currentPage + 1} of ${controller.totalPages}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: controller.isDarkMode 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              controller.isBookmarked(controller.currentPage)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: () => controller.toggleBookmark(),
          ),
          IconButton(
            icon: Icon(
              controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => controller.toggleDarkMode(),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'bookmarks',
                child: Text('Bookmarks'),
              ),
              const PopupMenuItem(
                value: 'notes',
                child: Text('Notes'),
              ),
              const PopupMenuItem(
                value: 'fullscreen',
                child: Text('Full Screen'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showSettingsDialog(context, controller);
                  break;
                case 'bookmarks':
                  _showBookmarksDialog(context, controller);
                  break;
                case 'notes':
                  _showNotesDialog(context, controller);
                  break;
                case 'fullscreen':
                  controller.toggleFullScreen();
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(ReaderController controller) {
    if (controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (controller.book!.fileType == AppConstants.fileTypePDF) {
      return _buildPDFReader(controller);
    } else if (controller.book!.fileType == AppConstants.fileTypeEPUB) {
      return _buildEPUBReader(controller);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Unsupported file type',
              style: TextStyle(
                color: controller.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPDFReader(ReaderController controller) {
    // For demo, show sample content
    // In production, use actual PDF file URL with Syncfusion PDF Viewer
    final content = SampleContent.getSampleContent(controller.book?.id ?? '');
    
    return Container(
      color: controller.isDarkMode ? Colors.grey[900] : Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(controller.fontSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title
            Text(
              controller.book?.title ?? 'Book',
              style: TextStyle(
                fontSize: controller.fontSize + 6,
                fontWeight: FontWeight.bold,
                color: controller.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Author
            Text(
              'By ${controller.book?.authorName ?? "Unknown Author"}',
              style: TextStyle(
                fontSize: controller.fontSize - 2,
                color: controller.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            // Content
            Text(
              content,
              style: TextStyle(
                fontSize: controller.fontSize,
                height: controller.lineHeight,
                color: controller.isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.readingProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${controller.getProgressText()}',
                    style: TextStyle(
                      color: controller.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.currentPage > 0
                      ? () => controller.previousPage()
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: controller.currentPage < controller.totalPages - 1
                      ? () => controller.nextPage()
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEPUBReader(ReaderController controller) {
    // EPUB reader with sample content
    final content = SampleContent.getEPUBSampleContent(controller.book?.id ?? '');
    
    return Container(
      color: controller.isDarkMode ? Colors.grey[900] : Colors.white,
      padding: EdgeInsets.all(controller.fontSize),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title
            Text(
              controller.book?.title ?? 'Book',
              style: TextStyle(
                fontSize: controller.fontSize + 6,
                fontWeight: FontWeight.bold,
                color: controller.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              'By ${controller.book?.authorName ?? "Unknown Author"}',
              style: TextStyle(
                fontSize: controller.fontSize - 2,
                color: controller.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            // Content with proper formatting
            Text(
              content,
              style: TextStyle(
                fontSize: controller.fontSize,
                height: controller.lineHeight,
                color: controller.isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.readingProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${controller.getProgressText()}',
                    style: TextStyle(
                      color: controller.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.currentPage > 0
                      ? () => controller.previousPage()
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: controller.currentPage < controller.totalPages - 1
                      ? () => controller.nextPage()
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, ReaderController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isDarkMode 
            ? Colors.grey[850] 
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => controller.toggleBookmark(),
            tooltip: 'Bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () => _showAddNoteDialog(context, controller),
            tooltip: 'Add Note',
          ),
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: () => _showFontSizeDialog(context, controller),
            tooltip: 'Font Size',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => _showBrightnessDialog(context, controller),
            tooltip: 'Brightness',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, controller),
            tooltip: 'Settings',
          ),
        ],
      ),
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
