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
    // Ensure controllers are ready
    final paymentController = Get.find<PaymentController>();
    final bookController = Get.find<BookController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: Obx(() {
        // For now, we only have book IDs. We need to find the book objects from BookController.
        // In a real app, we might fetch purchased books specifically.
        // Here we filter the loaded books.
        
        // This logic presumes bookController.books contains all books. 
        // In a real app we'd fetch library books separately.
        final libraryBooks = bookController.books.where((book) {
          return paymentController.canAccessBook(book.id);
        }).toList();

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
                     // The parent controller should handle tab switching, 
                     // or we can navigate back if this is pushed on stack, 
                     // but here we are likely in a tab. Only HomeView knows how to switch tabs easily 
                     // unless we use a global controller or event. 
                     // For now, simple text is enough.
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
            crossAxisCount: 2,
            childAspectRatio: 0.62, // consistent with HomeView
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: libraryBooks.length,
          itemBuilder: (context, index) {
            final book = libraryBooks[index];
            return BookCard(
              book: book,
              showWishlistButton: false,
              onTap: () => Get.toNamed(AppConstants.bookDetailRoute, arguments: book),
            );
          },
        );
      }),
    );
  }
}
