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
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();

  Timer? _debounce;

  bool _isFilterExpanded = false;
  String _selectedLanguage = 'All';

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

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
              "Explore Books",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 20),

            /// SEARCH BAR
            AppSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (q) => bookController.searchBooks(q),
              onFilter: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),

            const SizedBox(height: 16),

            /// OPTIONAL FILTER PANEL
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isFilterExpanded
                  ? _buildFilterPanel(bookController)
                  : const SizedBox.shrink(),
            ),

            if (_isFilterExpanded) const SizedBox(height: 16),

            /// CATEGORY PILLS
            Obx(() {
              if (bookController.isCategoriesLoading) {
                return const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final categories = bookController.categories;
              final currentGenre = bookController.selectedGenre;

              return SizedBox(
                height: 40,
                child: ListView.separated(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final isAll = index == 0;
                    final label = isAll ? "All" : categories[index - 1];

                    final isSelected = currentGenre == label ||
                        (isAll && currentGenre.isEmpty);

                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        bookController.filterByGenre(isAll ? '' : label);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            /// SEARCH RESULTS
            Expanded(
              child: Obx(() {
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
                          Icons.search_off,
                          size: 60,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(100),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No books found",
                          style: Theme.of(context).textTheme.titleMedium,
                        )
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
                    childAspectRatio: 0.42,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (_, index) {
                    if (index == books.length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Align(
                      alignment: Alignment.topCenter,
                      child: BookCard(
                        book: books[index],
                        onTap: () => Get.toNamed(
                          AppConstants.bookDetailRoute,
                          arguments: books[index],
                        ),
                      ),
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(BookController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: "Language",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "All", child: Text("All")),
                DropdownMenuItem(value: "English", child: Text("English")),
                DropdownMenuItem(value: "Mizo", child: Text("Mizo")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                  controller.filterByLanguage(val == "All" ? "" : val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
