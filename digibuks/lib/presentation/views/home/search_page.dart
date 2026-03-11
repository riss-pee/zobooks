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
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Get.find<BookController>().searchBooks(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              onFilter: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
            const SizedBox(height: 16),

            // 2. Expandable Filter Section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isFilterExpanded
                  ? _buildFilterSection(bookController)
                  : const SizedBox.shrink(),
            ),
            if (_isFilterExpanded) const SizedBox(height: 16),

            // 4. Book Cards (Results)
            Expanded(
              child: Obx(() {
                if (bookController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = bookController.filteredBooks;
                if (books.isEmpty) {
                  return const Center(child: Text('No books found'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount: books.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.48,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return BookCard(
                      book: books[index],
                      onTap: () => Get.toNamed(AppConstants.bookDetailRoute,
                          arguments: books[index]),
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

  Widget _buildFilterSection(BookController bookController) {
    final selectedCategory = bookController.selectedGenre.isEmpty
        ? 'All'
        : bookController.selectedGenre;
    final selectedLanguage = bookController.selectedLanguage.isEmpty
        ? 'All'
        : bookController.selectedLanguage;
    final categories = bookController.availableCategories.isEmpty
        ? const ['All']
        : bookController.availableCategories;
    final languages = bookController.availableLanguages.isEmpty
        ? const ['All']
        : bookController.availableLanguages;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keywords',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  bookController
                      .filterByGenre(category == 'All' ? '' : category);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color:
                                Theme.of(context).dividerColor.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(category),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Language',
                  value: selectedLanguage,
                  items: languages,
                  onChanged: (val) {
                    bookController.filterByLanguage(val == 'All' ? '' : val!);
                  },
                  itemLabelBuilder: _formatLanguageLabel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Sort By',
                  value: bookController.sortBy,
                  items: [
                    'Newest',
                    'Oldest',
                    'Price: Low to High',
                    'Price: High to Low'
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      bookController.setSortBy(val);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String item)? itemLabelBuilder,
  }) {
    final selectedValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(80),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Theme.of(context).dividerColor.withAlpha(30)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(itemLabelBuilder?.call(item) ?? item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _formatLanguageLabel(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return 'English';
      case 'mizo':
        return 'Mizo';
      case 'all':
        return 'All';
      default:
        if (language.isEmpty) {
          return 'All';
        }
        return language[0].toUpperCase() + language.substring(1);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'history':
        return Icons.history_edu;
      case 'novel':
        return Icons.auto_stories;
      case 'sci-fi':
        return Icons.rocket_launch_outlined;
      case 'horror':
        return Icons.nightlight_round;
      case 'all':
        return Icons.apps;
      default:
        return Icons.menu_book;
    }
  }
}
