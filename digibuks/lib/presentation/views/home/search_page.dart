import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/language_controller.dart';
import '../../widgets/book_card.dart';
import '../../widgets/search_bar.dart';
import '../../../core/constants/app_constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();
  bool _isFilterExpanded = false;
  late AnimationController _filterAnimationController;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Default call with no query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<BookController>();
      if (controller.categories.isEmpty) {
        controller.loadCategories();
      }
      controller.searchBooksByApi('');
    });

    _gridScrollController.addListener(() {
      if (_gridScrollController.position.pixels >=
          _gridScrollController.position.maxScrollExtent - 200) {
        Get.find<BookController>().loadMoreBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _categoryScrollController.dispose();
    _gridScrollController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Get.find<BookController>().searchBooks(query);
    });
  }

  void _toggleFilter() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
      if (_isFilterExpanded) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  Widget _buildFilterPanel(
      BookController bookController, LanguageController languageController) {
    return Obx(() {
      if (bookController.isCategoriesLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }

      final categories = bookController.categories;
      final currentGenre = bookController.selectedGenre;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withAlpha(80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // "All" option
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    bookController.filterByGenre('');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: currentGenre.isEmpty
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                      border: currentGenre.isEmpty
                          ? null
                          : Border.all(
                              color:
                                  Theme.of(context).dividerColor.withAlpha(50)),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: currentGenre.isEmpty
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: currentGenre.isEmpty
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Category options
                ...categories.map((category) {
                  final isSelected = currentGenre == category.name;
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      bookController.filterByGenre(category.name);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withAlpha(100),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withAlpha(50)),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final languageController = Get.find<LanguageController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Obx(() {
              // Access language observable to make GetX listen
              languageController.language;
              return Text(
                languageController.translate('explore_books'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              );
            }),
            const SizedBox(height: 20),

            // 1. Search Bar
            AppSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (query) => bookController.searchBooks(query),
              onFilter: _toggleFilter,
            ),
            const SizedBox(height: 16),

            // 2. Collapsible Filter Panel
            SizeTransition(
              sizeFactor: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                    parent: _filterAnimationController,
                    curve: Curves.easeInOut),
              ),
              axisAlignment: -1.0,
              child: _buildFilterPanel(bookController, languageController),
            ),

            // 3. Book Cards (Results)
            Expanded(
              child: Obx(() {
                if (bookController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Using bookController.filteredBooks will use the already updated _books
                final books = bookController.filteredBooks;

                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(100)),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(150),
                                  ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  controller: _gridScrollController,
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount:
                      books.length + (bookController.isLoadingMore ? 1 : 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio:
                        0.42, // Adjusted to fix bottom overflow (width / totalHeight)
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    if (index == books.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Align(
                      alignment: Alignment.topCenter,
                      child: BookCard(
                        book: books[index],
                        onTap: () => Get.toNamed(AppConstants.bookDetailRoute,
                            arguments: books[index]),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
