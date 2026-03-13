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
        appBar: AppBar(
          title: Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Cover
              Center(
                child: SizedBox(
                  height: 220,
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.coverImage != null
                        ? Image.network(
                            book.coverImage!,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholder(context),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Title
              Center(
                child: Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 6),

              /// Author
              Center(
                child: Text(
                  _getAuthorsDisplay(book),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 20),

              /// Meta Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetaItem(
                    context,
                    Icons.language,
                    'Language',
                    _getLanguageDisplay(book.language),
                  ),
                  _buildMetaItem(
                    context,
                    Icons.monetization_on,
                    'Price',
                    book.price != null && book.price! > 0
                        ? '₹${book.price!.toStringAsFixed(0)}'
                        : 'Free',
                  ),
                  if (book.chapters.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showChaptersModal(context, book),
                      child: Column(
                        children: [
                          Icon(Icons.list),
                          const SizedBox(height: 6),
                          const Text('Chapters'),
                          Text('${book.chapters.length}')
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              if (bookController.isLoadingDetails.value)
                const Center(child: CircularProgressIndicator()),

              if (book.description != null && book.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About this book',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

              const SizedBox(height: 28),

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
      child: const Icon(Icons.menu_book, size: 80),
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
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, BookModel book) {
    return Obx(() {
      final hasAccess = paymentController.canAccessBook(book.id);

      return Column(
        children: [
          /// Wishlist
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => bookController.toggleWishlist(book.id),
              icon: const Icon(Icons.favorite_border),
              label: const Text("Add to Wishlist"),
            ),
          ),

          const SizedBox(height: 16),

          /// Main Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (hasAccess) {
                  Get.toNamed(AppConstants.readerRoute, arguments: book);
                } else if (book.price == null || book.price! <= 0) {
                  if (!authController.isAuthenticated) {
                    _showLoginRequiredModal(context);
                  } else {
                    paymentController.claimFreeBook(book);
                  }
                } else {
                  if (!authController.isAuthenticated) {
                    _showLoginRequiredModal(context);
                  } else {
                    paymentController.purchaseBook(book);
                  }
                }
              },
              child: Text(
                hasAccess
                    ? 'Read Now'
                    : book.price == null || book.price! <= 0
                        ? 'Get Free'
                        : 'Buy for ₹${book.price!.toStringAsFixed(0)}',
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showLoginRequiredModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 40),
              const SizedBox(height: 12),
              const Text('Login Required'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(AppConstants.loginRoute);
                },
                child: const Text("Log In"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChaptersModal(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: book.chapters.length,
          itemBuilder: (_, i) {
            final c = book.chapters[i];

            return ListTile(
              title: Text(c.title),
              subtitle: Text('${c.wordCount} words'),
            );
          },
        );
      },
    );
  }
}
