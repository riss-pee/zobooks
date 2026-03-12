import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/reader_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/glass_container.dart';

class ReaderView extends StatelessWidget {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReaderController>();

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
          child: controller.isLoading
              ? _buildLoadingState(context, controller)
              : controller.chapters.isEmpty
                  ? _buildEmptyState(context, controller)
                  : Stack(
                      children: [
                        // Reader Content
                        _buildChapterContent(context, controller),

                        // Top App Bar
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: controller.isFullScreen ? -120 : 0,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: controller.isFullScreen ? 0.0 : 1.0,
                            child: _buildAppBar(context, controller),
                          ),
                        ),

                        // Bottom Bar
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          bottom: controller.isFullScreen ? -100 : 0,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: controller.isFullScreen ? 0.0 : 1.0,
                            child: _buildBottomBar(context, controller),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ReaderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading book...',
            style: TextStyle(
              color: controller.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReaderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 64,
              color: controller.isDarkMode ? Colors.white38 : Colors.black26),
          const SizedBox(height: 16),
          Text(
            'No chapters available',
            style: TextStyle(
              color: controller.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, ReaderController controller) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            controller.isDarkMode
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            controller.isDarkMode
                ? Colors.black.withOpacity(0.0)
                : Colors.white.withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: controller.isDarkMode ? Colors.white : AppTheme.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.book!.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: controller.isDarkMode ? Colors.white : AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  controller.currentChapterTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: controller.isDarkMode ? Colors.white60 : AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Bookmark toggle
          IconButton(
            icon: Icon(
              controller.isCurrentChapterBookmarked()
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: controller.isCurrentChapterBookmarked()
                  ? AppTheme.primaryColor
                  : (controller.isDarkMode ? Colors.white : AppTheme.textDark),
            ),
            onPressed: () => controller.toggleBookmark(),
          ),
          // Settings
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: controller.isDarkMode ? Colors.white : AppTheme.textDark),
            onPressed: () => _showSettingsSheet(context, controller),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, ReaderController controller) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            controller.isDarkMode
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            controller.isDarkMode
                ? Colors.black.withOpacity(0.0)
                : Colors.white.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chapter progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapter ${controller.currentChapterIndex + 1} of ${controller.totalChapters}',
                style: TextStyle(
                  fontSize: 12,
                  color: controller.isDarkMode ? Colors.white54 : Colors.black45,
                ),
              ),
              Text(
                controller.getProgressText(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: controller.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: controller.isDarkMode ? Colors.white12 : Colors.black12,
              thumbColor: AppTheme.primaryColor,
            ),
            child: Slider(
              value: controller.totalChapters > 0
                  ? controller.currentChapterIndex.toDouble()
                  : 0,
              min: 0,
              max: controller.totalChapters > 0
                  ? (controller.totalChapters - 1).toDouble()
                  : 1,
              divisions: controller.totalChapters > 1
                  ? controller.totalChapters - 1
                  : null,
              onChanged: (v) => controller.goToChapter(v.toInt()),
            ),
          ),
          // Action buttons only (no prev/next — use swipe)
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.list_rounded,
                    color: controller.isDarkMode ? Colors.white70 : Colors.black54),
                onPressed: () => _showTableOfContents(context, controller),
                tooltip: 'Chapters',
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.bookmarks_outlined,
                    color: controller.isDarkMode ? Colors.white70 : Colors.black54),
                onPressed: () => _showBookmarksSheet(context, controller),
                tooltip: 'Bookmarks',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chapter Content ────────────────────────────────────────

  Widget _buildChapterContent(BuildContext context, ReaderController controller) {
    // Determine colors based on theme
    Color bgColor;
    Color textColor;

    switch (controller.themeType) {
      case 'sepia':
        bgColor = const Color(0xFFF4ECD8);
        textColor = const Color(0xFF5B4636);
        break;
      case 'dark':
        bgColor = const Color(0xFF1A1C1E);
        textColor = const Color(0xFFE2E2E6);
        break;
      default:
        bgColor = Colors.white;
        textColor = const Color(0xFF1A1C1E);
    }

    return Positioned.fill(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          // Swipe left → next chapter
          if (details.primaryVelocity! < -200) {
            controller.nextChapter();
          }
          // Swipe right → previous chapter
          if (details.primaryVelocity! > 200) {
            controller.previousChapter();
          }
        },
        child: Stack(
          children: [
            // Main content - fill entire screen
            Positioned.fill(
              child: Container(
                color: bgColor,
                child: controller.isChapterLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        controller: controller.scrollController,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 72,
                          bottom: MediaQuery.of(context).padding.bottom + 120,
                          left: 24,
                          right: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chapter title
                            Text(
                              controller.currentChapterTitle,
                              style: _getTextStyle(controller,
                                fontSize: controller.fontSize + 8,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 40, height: 3,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Chapter text
                            Text(
                              controller.currentChapterContent,
                              style: _getTextStyle(controller,
                                fontSize: controller.fontSize,
                                height: controller.lineHeight,
                                color: textColor.withOpacity(0.9),
                              ),
                              textAlign: controller.textAlign == 'justify'
                                  ? TextAlign.justify
                                  : TextAlign.left,
                            ),
                            const SizedBox(height: 60),
                            // End of book indicator
                            if (controller.currentChapterIndex == controller.totalChapters - 1)
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.auto_stories_rounded,
                                        size: 40, color: textColor.withOpacity(0.3)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'End of Book',
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.5),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
              ),
            ),
            // Hidden tap zone — left edge (previous chapter)
            if (controller.currentChapterIndex > 0)
              Positioned(
                left: 0,
                top: MediaQuery.of(context).padding.top + 80,
                bottom: MediaQuery.of(context).padding.bottom + 100,
                width: 44,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => controller.previousChapter(),
                  child: const SizedBox.expand(),
                ),
              ),
            // Hidden tap zone — right edge (next chapter)
            if (controller.currentChapterIndex < controller.totalChapters - 1)
              Positioned(
                right: 0,
                top: MediaQuery.of(context).padding.top + 80,
                bottom: MediaQuery.of(context).padding.bottom + 100,
                width: 44,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => controller.nextChapter(),
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Table of Contents ──────────────────────────────────────

  void _showTableOfContents(BuildContext context, ReaderController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: controller.isDarkMode
              ? const Color(0xFF1E1E2C)
              : const Color(0xFFF8F9FA),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: controller.isDarkMode ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Chapters',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: controller.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${controller.chapters.length} chapters',
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: controller.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = controller.chapters[index];
                  final isCurrent = index == controller.currentChapterIndex;
                  final sectionType = chapter['section_type'] ?? 'chapter';

                  return ListTile(
                    leading: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.primaryColor
                            : (controller.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : (controller.isDarkMode ? Colors.white54 : Colors.black45),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      chapter['title'] ?? 'Chapter ${index + 1}',
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? AppTheme.primaryColor
                            : (controller.isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                    subtitle: Text(
                      sectionType == 'chapter'
                          ? '${chapter['word_count'] ?? 0} words'
                          : sectionType.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Icon(Icons.play_arrow_rounded,
                            color: AppTheme.primaryColor, size: 20)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      controller.goToChapter(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bookmarks Sheet ────────────────────────────────────────

  void _showBookmarksSheet(BuildContext context, ReaderController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Obx(() => Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: controller.isDarkMode
                  ? const Color(0xFF1E1E2C)
                  : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: controller.isDarkMode ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Bookmarks',
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,
                          color: controller.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${controller.bookmarks.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.isDarkMode ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: controller.bookmarks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_border_rounded,
                                  size: 48,
                                  color: controller.isDarkMode
                                      ? Colors.white24
                                      : Colors.black12),
                              const SizedBox(height: 12),
                              Text(
                                'No bookmarks yet',
                                style: TextStyle(
                                  color: controller.isDarkMode
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.bookmarks.length,
                          itemBuilder: (context, index) {
                            final bookmark = controller.bookmarks[index];
                            final location = bookmark['location']
                                as Map<String, dynamic>?;

                            return ListTile(
                              leading: const Icon(Icons.bookmark_rounded,
                                  color: AppTheme.primaryColor),
                              title: Text(
                                location?['chapter_title'] ?? 'Bookmark',
                                style: TextStyle(
                                  color: controller.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Chapter ${(location?['chapter_index'] ?? 0) + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: controller.isDarkMode
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: controller.isDarkMode
                                        ? Colors.white38
                                        : Colors.black38,
                                    size: 20),
                                onPressed: () {
                                  controller.deleteBookmark(
                                      bookmark['id'].toString());
                                },
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                final chapterIdx =
                                    location?['chapter_index'] as int? ?? 0;
                                controller.goToChapter(chapterIdx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          )),
    );
  }

  // ── Delete bookmark helper ────────────────────────────────
  void deleteBookmark(ReaderController controller, String id) {
    controller.deleteBookmark(id);
  }

  // ── Settings Sheet ─────────────────────────────────────────

  void _showSettingsSheet(BuildContext context, ReaderController controller) {
    Get.bottomSheet(
      Obx(() => Container(
            decoration: BoxDecoration(
              color: controller.isDarkMode
                  ? const Color(0xFF1E1E2C)
                  : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: controller.isDarkMode ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Reader Settings',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: controller.isDarkMode ? Colors.white : Colors.black87,
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
                    value: controller.fontSize, min: 12, max: 32,
                    onChanged: (v) => controller.setFontSize(v),
                    label: '${controller.fontSize.toInt()}',
                    controller: controller,
                  ),
                  const SizedBox(height: 24),

                  // Font Family
                  _buildSectionTitle('FONT', controller),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _buildFontButton('Georgia', controller),
                      _buildFontButton('Merriweather', controller),
                      _buildFontButton('Inter', controller),
                      _buildFontButton('Open Sans', controller),
                      _buildFontButton('JetBrains Mono', controller),
                      _buildFontButton('OpenDyslexic', controller),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Text Align
                  _buildSectionTitle('TEXT ALIGN', controller),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAlignButton('Left', 'left', Icons.format_align_left_rounded, controller),
                      const SizedBox(width: 12),
                      _buildAlignButton('Justify', 'justify', Icons.format_align_justify_rounded, controller),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Line Height
                  _buildSectionTitle('LINE HEIGHT', controller),
                  _buildSlider(
                    value: controller.lineHeight, min: 1.0, max: 2.5,
                    onChanged: (v) => controller.setLineHeight(v),
                    label: controller.lineHeight.toStringAsFixed(1),
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

  // ── Shared Setting Widgets ─────────────────────────────────

  Widget _buildSectionTitle(String title, ReaderController controller) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2,
        color: controller.isDarkMode ? Colors.white54 : Colors.black45,
      ),
    );
  }

  Widget _buildThemeButton(String label, String type, ReaderController controller) {
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
            label, textAlign: TextAlign.center,
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

  /// Get a TextStyle using GoogleFonts based on the controller's font family
  TextStyle _getTextStyle(ReaderController controller, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
    switch (controller.fontFamily) {
      case 'Merriweather':
        return GoogleFonts.merriweather(textStyle: baseStyle);
      case 'Inter':
        return GoogleFonts.inter(textStyle: baseStyle);
      case 'Open Sans':
        return GoogleFonts.openSans(textStyle: baseStyle);
      case 'JetBrains Mono':
        return GoogleFonts.jetBrainsMono(textStyle: baseStyle);
      case 'OpenDyslexic':
        // OpenDyslexic is not in google_fonts; fall back to system
        return baseStyle.copyWith(fontFamily: 'OpenDyslexic');
      case 'Georgia':
      default:
        return baseStyle.copyWith(fontFamily: 'Georgia');
    }
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
          style: _getTextStyle(controller,
            fontSize: 14,
            color: isSelected
                ? Colors.white
                : (controller.isDarkMode ? Colors.white70 : Colors.black87),
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
              Icon(icon, size: 18,
                  color: isSelected
                      ? Colors.white
                      : (controller.isDarkMode ? Colors.white70 : Colors.black87)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (controller.isDarkMode ? Colors.white70 : Colors.black87),
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
            value: value, min: min, max: max,
            onChanged: (v) => onChanged(v),
            activeColor: AppTheme.primaryColor,
            inactiveColor: controller.isDarkMode ? Colors.white10 : Colors.black12,
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
}
