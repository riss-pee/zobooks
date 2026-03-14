import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/book_controller.dart';
import '../../widgets/book_card.dart';
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
          return const Center(
            child: CircularProgressIndicator(),
          );
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
                    // Could switch to Home tab
                  },
                  child: const Text('Go explore books'),
                )
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: libraryBooks.length,
          itemBuilder: (context, index) {
            final book = libraryBooks[index];

            return BookCard(
              book: book,
              showWishlistButton: false,
              onTap: () {
                Get.toNamed(
                  AppConstants.readerRoute,
                  arguments: book,
                );
              },
            );
          },
        );
      }),
    );
  }
}
