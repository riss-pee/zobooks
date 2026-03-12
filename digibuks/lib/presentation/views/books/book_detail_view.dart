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

class BookDetailView extends StatefulWidget {
  const BookDetailView({super.key});

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  late BookModel initialBook;
  final bookController = Get.find<BookController>();
  final authController = Get.find<AuthController>();
  final themeController = Get.find<ThemeController>();
  final paymentController = Get.find<PaymentController>();

  @override
  void initState() {
    super.initState();
    // Use the passed argument as the fallback initial book.
    final arg = Get.arguments as BookModel?;
    if (arg != null) {
      initialBook = arg;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bookController.fetchBookDetails(initialBook.id);
        // Check ownership if user is authenticated
        if (authController.isAuthenticated) {
          paymentController.checkOwnership(initialBook.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Details')),
        body: const Center(child: Text('Book not found')),
      );
    }

    return Obx(() {
      final isDark = themeController.isDarkMode;
      final book = bookController.currentBook.value ?? initialBook;
      
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
          title: Text(
            book.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image - centered and compact
              Center(
                child: Container(
                  height: 220,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.coverImage != null && book.coverImage!.isNotEmpty
                        ? Image.network(
                            book.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                          )
                        : _buildPlaceholder(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Author - centered
              Center(
                child: Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  _getAuthorsDisplay(book),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Meta Row: Language, Price, Chapters button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetaItem(context, Icons.language_rounded, 'Language',
                      _getLanguageDisplay(book.language)),
                  _buildMetaItem(
                      context,
                      Icons.monetization_on_rounded,
                      'Price',
                      book.price != null && book.price! > 0
                          ? '₹${book.price!.toStringAsFixed(0)}'
                          : 'Free'),
                  // Chapters button as a meta item
                  if (book.chapters.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showChaptersModal(context, book),
                      child: Column(
                        children: [
                          Icon(Icons.list_alt_rounded,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                          const SizedBox(height: 8),
                          Text(
                            'Chapters',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${book.chapters.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Loading indicator
              if (bookController.isLoadingDetails.value)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Description
              if (book.description != null && book.description!.isNotEmpty) ...[
                Text(
                  'About this book',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Action Buttons
              _buildActionButtons(context, book, bookController, authController),
              const SizedBox(height: 32),
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

  String _getAuthorsDisplay(BookModel book) {
    if (book.authors.isNotEmpty) {
      return book.authors.map((a) => a.name).join(', ');
    }
    return book.authorName ?? 'Unknown Author';
  }

  String _getLanguageDisplay(String code) {
    const languageMap = {
      'en': 'English',
      'mizo': 'Mizo',

    };
    return languageMap[code.toLowerCase()] ?? code.toUpperCase();
  }

  // _buildMetaSection removed - meta items now inline in build()

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
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
fontWeight: FontWeight.bold),
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
              onPressed: paymentController.isProcessing
                  ? null
                  : () {
                if (hasAccess) {
                  Get.toNamed(AppConstants.readerRoute, arguments: book);
                } else if (book.type == AppConstants.bookTypeFree || (book.price == null || book.price! <= 0)) {
                  if (!authController.isAuthenticated) {
                    _showLoginRequiredModal(context);
                  } else {
                    paymentController.claimFreeBook(book);
                  }
                } else if (!authController.isAuthenticated) {
                  _showLoginRequiredModal(context);
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
                  Icon(hasAccess
                      ? Icons.auto_stories_rounded
                      : (book.type == AppConstants.bookTypeFree || (book.price == null || book.price! <= 0))
                          ? Icons.download_rounded
                          : Icons.shopping_bag_rounded),
                  const SizedBox(width: 12),
                  paymentController.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                    hasAccess
                        ? 'Read Now'
                        : (book.type == AppConstants.bookTypeFree || (book.price == null || book.price! <= 0))
                            ? 'Get Free'
                            : book.type == AppConstants.bookTypeRental
                                ? 'Rent for ₹${book.rentalPrice?.toStringAsFixed(0)}'
                                : 'Buy for ₹${book.price?.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
              ),
            ),
          ],
        ],
      );
    });
  }

  void _showLoginRequiredModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Login Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need to log in to purchase this book.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.toNamed(AppConstants.loginRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePurchase(BuildContext context, BookModel book) {
    final paymentController = Get.find<PaymentController>();
    paymentController.purchaseBook(book);
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

  void _showChaptersModal(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chapters',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                        ),
                        ),
                        Text(
                          '${book.chapters.length} Items',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: book.chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = book.chapters[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${chapter.index}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${chapter.wordCount} words • ${chapter.sectionType.replaceAll('_', ' ').capitalizeFirst}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                          onTap: () {
                            Navigator.pop(context); // Close modal
                            // Future: Action to go directly to this chapter in ReaderView
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
