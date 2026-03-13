import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/book_controller.dart';
import '../../controllers/payment_controller.dart';

import '../../widgets/book_card.dart';

import '../../../core/constants/app_constants.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final bookController = Get.find<BookController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: Obx(() {
        /// Filter books the user owns
        final libraryBooks = bookController.books.where((book) {
          return paymentController.canAccessBook(book.id);
        }).toList();

        /// Empty Library UI
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
                    /// In future this could switch to Home tab
                  },
                  child: const Text('Go explore books'),
                ),
              ],
            ),
          );
        }

        /// Library Books Grid
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
              onTap: () => Get.toNamed(
                AppConstants.bookDetailRoute,
                arguments: book,
              ),
            );
          },
        );
      }),
    );
  }
}
