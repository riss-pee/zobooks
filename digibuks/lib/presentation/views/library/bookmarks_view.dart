import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/bookmarks_controller.dart';
import '../../controllers/book_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/models/book_model.dart';

class BookmarksView extends StatefulWidget {
  const BookmarksView({super.key});

  @override
  State<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<BookmarksView> {
  late BookmarksController _bookmarksController;

  @override
  void initState() {
    super.initState();
    _bookmarksController = Get.find<BookmarksController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            if (_bookmarksController.chapterBookmarks.isEmpty) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Clear All'),
                  onTap: () {
                    _showClearConfirmationDialog(context);
                  },
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_bookmarksController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final bookmarks = _bookmarksController.chapterBookmarks;

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Bookmarks Yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bookmark your favorite books to read later',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.offNamed(AppConstants.homeRoute),
                  icon: const Icon(Icons.explore_rounded),
                  label: const Text('Explore Books'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  '${bookmarks.length} Bookmarked ${bookmarks.length == 1 ? 'Chapter' : 'Chapters'}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookmarks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  return _buildChapterBookmarkCard(context, bookmark);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChapterBookmarkCard(BuildContext context, dynamic bookmark) {
    final chapterBookmark = bookmark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _openBook(context, chapterBookmark);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Book Cover
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: chapterBookmark.bookCoverImage != null
                        ? CachedNetworkImage(
                            imageUrl: chapterBookmark.bookCoverImage!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.book_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                          )
                        : Icon(
                            Icons.book_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Bookmark Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapterBookmark.bookTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapterBookmark.chapterTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        // Chapter number and date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CH ${chapterBookmark.chapterIndex + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            if (chapterBookmark.createdAt != null)
                              Text(
                                _formatDate(chapterBookmark.createdAt!),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Remove Button
                  IconButton(
                    icon: const Icon(Icons.bookmark_rounded),
                    color: Colors.blue,
                    tooltip: 'Remove bookmark',
                    onPressed: () {
                      _bookmarksController.removeBookmark(chapterBookmark.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _openBook(BuildContext context, dynamic chapterBookmark) async {
    try {
      // Show loading indicator
      showSnackSafe('Opening', 'Loading ${chapterBookmark.bookTitle}...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));

      // Fetch book details
      final bookController = Get.find<BookController>();
      await bookController.fetchBookDetails(chapterBookmark.bookId);

      final book = bookController.currentBook.value;
      if (book != null) {
        // Navigate to reader with chapter information
        Get.toNamed(
          AppConstants.readerRoute,
          arguments: {
            'book': book,
            'chapterIndex': chapterBookmark.chapterIndex,
          },
        );
      } else {
        showSnackSafe('Error', 'Could not load book');
      }
    } catch (e) {
      showSnackSafe('Error', 'Failed to open book: $e');
    }
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear All Bookmarks?'),
        content: const Text(
          'Are you sure you want to remove all bookmarks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _bookmarksController.clearAllBookmarks();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
