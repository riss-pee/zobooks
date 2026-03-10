import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../../data/models/book_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/glass_container.dart';
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

    final bookController = Get.find<BookController>();
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F1113),
                    const Color(0xFF1A1C20),
                  ]
                : [
                    const Color(0xFFFFFBF0),
                    const Color(0xFFF7F0E0),
                  ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              // Liquid Glass App Bar
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image or Placeholder
                      book.coverImage != null
                          ? Image.network(
                              book.coverImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(context),
                            )
                          : _buildPlaceholder(context),
                      // Frosted Glass Header Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GlassContainer(
                          height: 80,
                          blur: 15,
                          opacity: isDark ? 0.3 : 0.2,
                          borderRadius: 0,
                          child: Container(), // Empty, just for the effect
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content Area
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section with Glass
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        blur: 10,
                        opacity: 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By ${book.authorName ?? "Unknown Author"}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                    fontFamily: 'Outfit',
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (book.rating != null)
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < book.rating!.floor()
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${book.rating!.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  if (book.reviewCount != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${book.reviewCount} reviews)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                            fontFamily: 'Outfit',
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Meta Info (Language, Pages, Genre)
                      _buildMetaSection(context, book),
                      const SizedBox(height: 24),
                      // Description Section
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.description ??
                            'No description available for this book.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                              fontFamily: 'Outfit',
                            ),
                      ),
                      const SizedBox(height: 32),
                      // Actions Section
                      _buildActionButtons(
                          context, book, bookController, authController),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 100,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildMetaSection(BuildContext context, BookModel book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetaItem(context, Icons.language_rounded, 'Language',
            book.language.toUpperCase()),
        if (book.pageCount != null)
          _buildMetaItem(
              context, Icons.menu_book_rounded, 'Pages', '${book.pageCount}'),
        _buildMetaItem(context, Icons.category_rounded, 'Genre',
            book.genres.isNotEmpty ? book.genres.first : 'General'),
      ],
    );
  }

  Widget _buildMetaItem(
      BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontFamily: 'Outfit',
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BookModel book,
    BookController bookController,
    AuthController authController,
  ) {
    final paymentController = Get.find<PaymentController>();

    return Obx(() {
      final hasAccess = paymentController.canAccessBook(book.id);
      final isInWishlist = bookController.isInWishlist(book.id);

      return Column(
        children: [
          // Wishlist Button - Glassy
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => bookController.toggleWishlist(book.id),
              icon: Icon(
                isInWishlist
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppTheme.primaryColor,
              ),
              label: Text(
                isInWishlist ? 'In Wishlist' : 'Add to Wishlist',
                style: const TextStyle(
                    fontFamily: 'Outfit', fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Main Purchase/Read Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (hasAccess || book.type == AppConstants.bookTypeFree) {
                  Get.toNamed(AppConstants.readerRoute, arguments: book);
                } else if (book.type == AppConstants.bookTypeRental) {
                  _handleRental(context, book);
                } else {
                  _handlePurchase(context, book);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasAccess || book.type == AppConstants.bookTypeFree
                      ? Icons.auto_stories_rounded
                      : Icons.shopping_bag_rounded),
                  const SizedBox(width: 12),
                  Text(
                    hasAccess || book.type == AppConstants.bookTypeFree
                        ? 'Read Now'
                        : book.type == AppConstants.bookTypeRental
                            ? 'Rent for ₹${book.rentalPrice?.toStringAsFixed(0)}'
                            : 'Buy for ₹${book.price?.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasAccess) ...[
            const SizedBox(height: 12),
            Text(
              'You have full access to this title',
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ],
      );
    });
  }

  void _handlePurchase(BuildContext context, BookModel book) {
    Get.to(() => PaymentView(
          book: book,
          paymentType: 'purchase',
        ));
  }

  void _handleRental(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(24),
        blur: 40,
        opacity: 0.25,
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rental Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
            ),
            const SizedBox(height: 24),
            ...([7, 14, 30].map((days) {
              final price = (book.rentalPrice ?? 0) * (days / 7);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.access_time_rounded,
                      size: 20, color: AppTheme.primaryColor),
                ),
                title: Text('$days Days Access',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('₹${price.toStringAsFixed(0)}'),
                trailing: const Icon(Icons.chevron_right_rounded),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
