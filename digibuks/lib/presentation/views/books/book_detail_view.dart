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

    final arg = Get.arguments as BookModel?;

    if (arg != null) {
      initialBook = arg;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        bookController.fetchBookDetails(initialBook.id);

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
              /// COVER IMAGE
              Center(
                child: Container(
                  height: 220,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        book.coverImage != null && book.coverImage!.isNotEmpty
                            ? Image.network(
                                book.coverImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(context),
                              )
                            : _buildPlaceholder(context),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              Center(
                child: Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 4),

              /// AUTHORS
              Center(
                child: Text(
                  _getAuthorsDisplay(book),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ),

              const SizedBox(height: 16),

              /// META INFO
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
                  if (book.chapters.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showChaptersModal(context, book),
                      child: _buildMetaItem(context, Icons.list_alt_rounded,
                          'Chapters', '${book.chapters.length}'),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              /// DESCRIPTION
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.75),
                      ),
                ),
              ],

              const SizedBox(height: 24),

              /// ACTION BUTTONS
              _buildActionButtons(context, book),

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

  Widget _buildActionButtons(BuildContext context, BookModel book) {
    return Obx(() {
      final hasAccess = paymentController.canAccessBook(book.id);
      final isInWishlist = bookController.isInWishlist(book.id);

      return Column(
        children: [
          /// WISHLIST
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => bookController.toggleWishlist(book.id),
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: AppTheme.primaryColor,
              ),
              label: Text(isInWishlist ? "In Wishlist" : "Add to Wishlist"),
            ),
          ),

          const SizedBox(height: 16),

          /// MAIN BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: paymentController.isProcessing
                  ? null
                  : () {
                      if (hasAccess) {
                        Get.toNamed(AppConstants.readerRoute, arguments: book);
                      } else if (!authController.isAuthenticated) {
                        Get.toNamed(AppConstants.loginRoute);
                      } else if (book.price == null || book.price == 0) {
                        paymentController.claimFreeBook(book);
                      } else {
                        paymentController.purchaseBook(book);
                      }
                    },
              child: paymentController.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      hasAccess
                          ? "Read Now"
                          : (book.price == null || book.price == 0)
                              ? "Get Free"
                              : "Buy for ₹${book.price!.toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      );
    });
  }

  void _showChaptersModal(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: book.chapters.length,
          itemBuilder: (_, index) {
            final chapter = book.chapters[index];

            return ListTile(
              title: Text(chapter.title),
              leading: Text("${chapter.index}"),
            );
          },
        );
      },
    );
  }
}
