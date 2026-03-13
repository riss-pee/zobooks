import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/reader_controller.dart';
import '../../../core/theme/app_theme.dart';

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

    return Obx(() => Scaffold(
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
                    ? const [
                        Color(0xFF1A1C1E),
                        Color(0xFF111417),
                        Color(0xFF0D0F11),
                      ]
                    : const [
                        Color(0xFFF5F5F5),
                        Color(0xFFEEEEEE),
                        Color(0xFFE0E0E0),
                      ],
              ),
            ),
            child: controller.isLoading
                ? _buildLoadingState(controller)
                : controller.chapters.isEmpty
                    ? _buildEmptyState(context, controller)
                    : Stack(
                        children: [
                          _buildChapterContent(context, controller),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            top: controller.isFullScreen ? -120 : 0,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: controller.isFullScreen ? 0 : 1,
                              child: _buildAppBar(context, controller),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            bottom: controller.isFullScreen ? -100 : 0,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: controller.isFullScreen ? 0 : 1,
                              child: _buildBottomBar(context, controller),
                            ),
                          ),
                        ],
                      ),
          ),
        ));
  }

  Widget _buildLoadingState(ReaderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            "Loading book...",
            style: TextStyle(
                color: controller.isDarkMode ? Colors.white70 : Colors.black54),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReaderController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book,
              size: 64,
              color: controller.isDarkMode ? Colors.white38 : Colors.black26),
          const SizedBox(height: 16),
          Text(
            "No chapters available",
            style: TextStyle(
                fontSize: 18,
                color: controller.isDarkMode ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Go Back"),
          )
        ],
      ),
    );
  }

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
          colors: [
            controller.isDarkMode
                ? Colors.black.withValues(alpha: .8)
                : Colors.white.withValues(alpha: .9),
            Colors.transparent
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color:
                    controller.isDarkMode ? Colors.white : AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.book!.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: controller.isDarkMode
                          ? Colors.white
                          : AppTheme.textDark),
                ),
                Text(
                  controller.currentChapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: controller.isDarkMode
                          ? Colors.white60
                          : AppTheme.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              controller.isCurrentChapterBookmarked()
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: controller.isCurrentChapterBookmarked()
                  ? AppTheme.primaryColor
                  : (controller.isDarkMode ? Colors.white : AppTheme.textDark),
            ),
            onPressed: controller.toggleBookmark,
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                color:
                    controller.isDarkMode ? Colors.white : AppTheme.textDark),
            onPressed: () => _showSettingsSheet(context, controller),
          )
        ],
      ),
    );
  }

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
          colors: [
            controller.isDarkMode
                ? Colors.black.withValues(alpha: .8)
                : Colors.white.withValues(alpha: .9),
            Colors.transparent
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "Chapter ${controller.currentChapterIndex + 1} / ${controller.totalChapters}",
                style: TextStyle(
                    fontSize: 12,
                    color: controller.isDarkMode
                        ? Colors.white60
                        : Colors.black45),
              ),
              const Spacer(),
              Text(
                controller.getProgressText(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: controller.isDarkMode
                        ? Colors.white70
                        : Colors.black54),
              ),
            ],
          ),
          Slider(
            value: controller.totalChapters > 0
                ? controller.currentChapterIndex.toDouble()
                : 0,
            min: 0,
            max: controller.totalChapters > 0
                ? (controller.totalChapters - 1).toDouble()
                : 1,
            onChanged: (v) => controller.goToChapter(v.toInt()),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => _showTableOfContents(context, controller),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmarks_outlined),
                onPressed: () => _showBookmarksSheet(context, controller),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChapterContent(
      BuildContext context, ReaderController controller) {
    Color bg;
    Color text;

    switch (controller.themeType) {
      case "sepia":
        bg = const Color(0xFFF4ECD8);
        text = const Color(0xFF5B4636);
        break;
      case "dark":
        bg = const Color(0xFF1A1C1E);
        text = const Color(0xFFE2E2E6);
        break;
      default:
        bg = Colors.white;
        text = const Color(0xFF1A1C1E);
    }

    return Positioned.fill(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;

          if (details.primaryVelocity! < -200) {
            controller.nextChapter();
          }
          if (details.primaryVelocity! > 200) {
            controller.previousChapter();
          }
        },
        child: Container(
          color: bg,
          child: SingleChildScrollView(
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
                Text(
                  controller.currentChapterTitle,
                  style: _getTextStyle(controller,
                      fontSize: controller.fontSize + 8,
                      fontWeight: FontWeight.bold,
                      color: text),
                ),
                const SizedBox(height: 24),
                Text(
                  controller.currentChapterContent,
                  textAlign: controller.textAlign == "justify"
                      ? TextAlign.justify
                      : TextAlign.left,
                  style: _getTextStyle(controller,
                      fontSize: controller.fontSize,
                      height: controller.lineHeight,
                      color: text.withValues(alpha: .9)),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTableOfContents(BuildContext context, ReaderController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        itemCount: controller.chapters.length,
        itemBuilder: (_, i) {
          final chapter = controller.chapters[i];
          return ListTile(
            title: Text(chapter["title"] ?? "Chapter ${i + 1}"),
            onTap: () {
              Navigator.pop(context);
              controller.goToChapter(i);
            },
          );
        },
      ),
    );
  }

  void _showBookmarksSheet(BuildContext context, ReaderController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Obx(() {
        if (controller.bookmarks.isEmpty) {
          return const Center(child: Text("No bookmarks yet"));
        }

        return ListView.builder(
          itemCount: controller.bookmarks.length,
          itemBuilder: (_, i) {
            final b = controller.bookmarks[i];
            final location = b["location"];

            return ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(location["chapter_title"] ?? "Bookmark"),
              subtitle: Text("Chapter ${(location["chapter_index"] ?? 0) + 1}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => controller.deleteBookmark(b["id"].toString()),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.goToChapter(location["chapter_index"]);
              },
            );
          },
        );
      }),
    );
  }

  void _showSettingsSheet(BuildContext context, ReaderController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Reader Settings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildThemeButton("Light", "light", controller),
                const SizedBox(width: 12),
                _buildThemeButton("Sepia", "sepia", controller),
                const SizedBox(width: 12),
                _buildThemeButton("Dark", "dark", controller),
              ],
            ),
            const SizedBox(height: 20),
            Slider(
              value: controller.fontSize,
              min: 12,
              max: 32,
              onChanged: controller.setFontSize,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildThemeButton(
      String label, String type, ReaderController controller) {
    final selected = controller.themeType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setThemeType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: selected ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }

  TextStyle _getTextStyle(ReaderController controller,
      {double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      double? height}) {
    final base = TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height);

    switch (controller.fontFamily) {
      case "Inter":
        return GoogleFonts.inter(textStyle: base);
      case "Open Sans":
        return GoogleFonts.openSans(textStyle: base);
      case "Merriweather":
        return GoogleFonts.merriweather(textStyle: base);
      case "JetBrains Mono":
        return GoogleFonts.jetBrainsMono(textStyle: base);
      default:
        return base.copyWith(fontFamily: "Georgia");
    }
  }
}
