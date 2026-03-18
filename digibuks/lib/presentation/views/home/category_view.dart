import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/language_controller.dart';
import '../../widgets/book_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/book_model.dart';

class CategoryView extends StatefulWidget {
  final String categoryName;
  final String? categoryBooks;

  const CategoryView({
    super.key,
    required this.categoryName,
    this.categoryBooks,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Load books for this category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<BookController>();
      // Handle special categories
      if (widget.categoryName.toLowerCase() == 'trending' ||
          widget.categoryName.toLowerCase() == 'latest') {
        // For trending and latest, just search with empty query to get all books
        // The HomeController handles these separately, so we use empty search
        controller.searchBooksByApi('');
      } else {
        // For regular categories, search with category filter
        controller.searchBooksByApi('', category: widget.categoryName);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Get.find<BookController>().loadMoreBooks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Translate category name to appropriate language
  String _getTranslatedCategoryName(
      String categoryName, LanguageController languageController) {
    final lowerName = categoryName.toLowerCase();

    // Map category names to translation keys
    const categoryKeyMap = {
      'trending': 'trending_now',
      'latest': 'latest_published',
      'latest published': 'latest_published',
      'history': 'history',
      'horror': 'horror',
      'novel': 'novel',
    };

    final key = categoryKeyMap[lowerName];
    if (key != null) {
      return languageController.translate(key);
    }

    // For unknown categories, return the original name
    return categoryName;
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          // Access language observable to make GetX listen
          languageController.language;
          return Text(_getTranslatedCategoryName(
              widget.categoryName, languageController));
        }),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(
        () {
          if (bookController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = bookController.filteredBooks;

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 80,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books in this category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Text(
                      languageController.translate('explore_books'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(150),
                          ),
                    );
                  }),
                ],
              ),
            );
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.45,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: books.length + (bookController.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == books.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final book = books[index];
              return BookCard(book: book);
            },
          );
        },
      ),
    );
  }
}
