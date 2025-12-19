import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/book_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class BookDetailView extends StatelessWidget {
  const BookDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final book = Get.arguments as BookModel?;
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Details')),
        body: const Center(child: Text('Book not found')),
      );
    }

    // Use find or putIfAbsent - controllers should be initialized via bindings
    final bookController = Get.find<BookController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: book.coverImage != null
                    ? Image.network(
                        book.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${book.authorName ?? "Unknown Author"}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Rating and Reviews
                  if (book.rating != null)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < book.rating!.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${book.rating!.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (book.reviewCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${book.reviewCount} reviews)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Book Info
                  _buildInfoRow(context, Icons.language, 'Language', book.language.toUpperCase()),
                  if (book.pageCount != null)
                    _buildInfoRow(context, Icons.menu_book, 'Pages', '${book.pageCount}'),
                  if (book.genres.isNotEmpty)
                    _buildInfoRow(context, Icons.category, 'Genre', book.genres.join(', ')),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description ?? 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  _buildActionButtons(context, book, bookController, authController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 80,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BookModel book,
    BookController bookController,
    AuthController authController,
  ) {
    return Column(
      children: [
        // Wishlist Button
        Obx(
          () => OutlinedButton.icon(
            onPressed: () => bookController.toggleWishlist(book.id),
            icon: Icon(
              bookController.isInWishlist(book.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            label: Text(
              bookController.isInWishlist(book.id)
                  ? 'Remove from Wishlist'
                  : 'Add to Wishlist',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Purchase/Rent/Read Button
        if (book.type == AppConstants.bookTypeFree)
          ElevatedButton(
            onPressed: () => Get.toNamed(AppConstants.readerRoute, arguments: book),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book),
                SizedBox(width: 8),
                Text('Read Free', style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        else if (book.type == AppConstants.bookTypeRental && book.rentalPrice != null)
          ElevatedButton(
            onPressed: () => _handleRental(context, book),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  'Rent for ₹${book.rentalPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
        else if (book.price != null)
          ElevatedButton(
            onPressed: () => _handlePurchase(context, book),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                Text(
                  'Buy for ₹${book.price!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _handlePurchase(BuildContext context, BookModel book) {
    Get.snackbar(
      'Purchase',
      'Purchase feature will be integrated with payment gateway',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implement payment integration
  }

  void _handleRental(BuildContext context, BookModel book) {
    Get.snackbar(
      'Rental',
      'Rental feature will be integrated with payment gateway',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implement rental payment integration
  }
}
