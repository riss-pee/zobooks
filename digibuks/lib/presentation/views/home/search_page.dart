import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../widgets/book_card.dart';
import '../../widgets/search_bar.dart';
import '../../../core/constants/app_constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Default call with no query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<BookController>();
      if (controller.categories.isEmpty) {
        controller.loadCategories();
      }
      controller.searchBooksByApi('');
    });

    _gridScrollController.addListener(() {
      if (_gridScrollController.position.pixels >= _gridScrollController.position.maxScrollExtent - 200) {
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
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Get.find<BookController>().searchBooks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Explore Books',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),

            // 1. Search Bar
            AppSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (query) => bookController.searchBooks(query),
            ),
            const SizedBox(height: 16),

            // 2. Category Pills
            Obx(() {
              if (bookController.isCategoriesLoading) {
                return const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final categories = bookController.categories;
              final currentGenre = bookController.selectedGenre; // MUST be accessed synchronously to track state

              return SizedBox(
                height: 40,
                child: ListView.separated(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1, // +1 for "All"
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final categoryLabel = isAll ? 'All' : categories[index - 1].name;
                    final isSelected = currentGenre == categoryLabel || 
                                      (isAll && currentGenre.isEmpty);

                    return GestureDetector(
                      onTap: () {
                        // Unfocus keyboard when tapping a category
                        FocusScope.of(context).unfocus();
                        bookController.filterByGenre(isAll ? '' : categoryLabel);
                        // Clear search text if desired, or keep it to search within category
                        // _searchController.clear();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: Theme.of(context).dividerColor.withAlpha(50)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categoryLabel,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),

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
                        Icon(Icons.search_off_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withAlpha(100)),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  controller: _gridScrollController,
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount: books.length + (bookController.isLoadingMore ? 1 : 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.42, // Adjusted to fix bottom overflow (width / totalHeight)
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
