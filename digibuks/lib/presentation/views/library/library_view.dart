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

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.60,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemCount: libraryBooks.length,
          itemBuilder: (context, index) {
            final book = libraryBooks[index];
            return InkWell(
              onTap: () {
                // Navigate to reader UI directly
                Get.toNamed(AppConstants.readerRoute, arguments: book);
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Cover
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.coverImage != null && book.coverImage!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: book.coverImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Icons.book, size: 40, color: Colors.grey),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  ),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(Icons.book, size: 40, color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Book Title
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.authorName != null && book.authorName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.authorName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
