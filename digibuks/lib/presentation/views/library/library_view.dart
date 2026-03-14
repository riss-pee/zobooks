import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/book_controller.dart';
import '../../../core/constants/app_constants.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  void initState() {
    super.initState();
    // Fetch user's library when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BookController>().fetchMyLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: Obx(() {
        if (bookController.isLoadingLibrary) {
          return const Center(child: CircularProgressIndicator());
        }

        final libraryBooks = bookController.myLibraryBooks;

        if (libraryBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your library is empty',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                     // Could implement navigation to home here, but usually tab switching is handled by the parent
                  },
                  child: const Text('Go explore books'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: libraryBooks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final book = libraryBooks[index];
            return InkWell(
              onTap: () {
                // Navigate to reader UI directly
                Get.toNamed(AppConstants.readerRoute, arguments: book);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Book Cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 90,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: book.coverImage != null && book.coverImage!.isNotEmpty
                             ? CachedNetworkImage(
                                 imageUrl: book.coverImage!,
                                 fit: BoxFit.cover,
                                 placeholder: (context, url) => const Icon(Icons.book, size: 30, color: Colors.grey),
                                 errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                               )
                             : const Icon(Icons.book, size: 30, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Book Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (book.authorName != null && book.authorName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              book.authorName!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Read Now',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
