import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../../data/models/book_model.dart';
import '../../../core/constants/app_constants.dart';
// removed unused import: app_theme
import '../payment/payment_view.dart';

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
                // Use a solid surface color behind the cover image
                color: Theme.of(context).colorScheme.primary.withAlpha(179),
                child: book.coverImage != null
                    ? Image.network(
                        book.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(bgColor: Theme.of(context).colorScheme.primary.withAlpha(26), iconColor: Theme.of(context).colorScheme.primary.withAlpha(128)),
                      )
                    : _buildPlaceholder(bgColor: Theme.of(context).colorScheme.primary.withAlpha(26), iconColor: Theme.of(context).colorScheme.primary.withAlpha(128)),
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
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(0xB3),
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
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(0xB3),
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

  Widget _buildPlaceholder({Color? bgColor, Color? iconColor}) {
    return Container(
      color: bgColor ?? const Color(0xFFF2F2F2),
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 80,
          color: iconColor ?? const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withAlpha(0xB3)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(0xB3),
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
    final paymentController = Get.find<PaymentController>();
    
    return Obx(
      () {
        final hasAccess = paymentController.canAccessBook(book.id);
        final hasPurchased = paymentController.hasPurchased(book.id);
        final hasRented = paymentController.hasRented(book.id);
        final rentalExpiry = paymentController.getRentalExpiry(book.id);

        return Column(
          children: [
            // Access Status
            if (hasAccess)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasPurchased
                            ? 'You own this book'
                            : hasRented && rentalExpiry != null
                                ? 'Rented until ${_formatDate(rentalExpiry)}'
                                : 'You have access',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (hasAccess) const SizedBox(height: 12),
            // Wishlist Button
            OutlinedButton.icon(
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
            const SizedBox(height: 12),
            // Read/Purchase/Rent Button
            if (hasAccess)
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
                    Text('Read Now', style: TextStyle(fontSize: 16)),
                  ],
                ),
              )
            else if (book.type == AppConstants.bookTypeFree)
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
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handlePurchase(BuildContext context, BookModel book) {
    Get.to(() => PaymentView(
      book: book,
      paymentType: 'purchase',
    ));
  }

  void _handleRental(BuildContext context, BookModel book) {
    // Show rental period selection
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Rental Period',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...([7, 14, 30].map((days) {
              final price = (book.rentalPrice ?? 0) * (days / 7);
              return ListTile(
                title: Text('$days days'),
                subtitle: Text('₹${price.toStringAsFixed(0)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(
                    AppConstants.paymentRoute,
                    arguments: {
                      'book': book,
                      'type': 'rental',
                      'rentalDays': days,
                    },
                  );
                },
              );
            })),
          ],
        ),
      ),
    );
  }
}
