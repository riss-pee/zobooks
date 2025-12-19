import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../widgets/book_card.dart';
import '../../../core/constants/app_constants.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: Obx(() {
        final wishlistIds = bookController.wishlist;
        
        final wishlistBooks = bookController.books.where((book) {
          return wishlistIds.contains(book.id);
        }).toList();

        if (wishlistBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your wishlist is empty',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
          itemCount: wishlistBooks.length,
          itemBuilder: (context, index) {
            final book = wishlistBooks[index];
            return BookCard(
              book: book,
              onTap: () => Get.toNamed(AppConstants.bookDetailRoute, arguments: book),
            );
          },
        );
      }),
    );
  }
}
