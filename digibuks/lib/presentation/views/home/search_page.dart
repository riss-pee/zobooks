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
  String _selectedCategory = 'All';
  String _selectedLanguage = 'All';
  String _sortBy = 'Newest';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps},
    {'label': 'Fiction', 'icon': Icons.auto_stories},
    {'label': 'Non‑Fiction', 'icon': Icons.menu_book},
    {'label': 'Poetry', 'icon': Icons.library_books},
    {'label': 'History', 'icon': Icons.history_edu},
    {'label': 'Education', 'icon': Icons.school},
  ];

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
              onFilter:
                  () {}, // Filter logic can be integrated or simplified here
            ),
            const SizedBox(height: 24),

            // 2. Keywords (Categories)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['label'];
                  return _buildCategoryChip(cat, isSelected, bookController);
                },
              ),
            ),
            const SizedBox(height: 24),

            // 3. Dropdown Buttons
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Language',
                    value: _selectedLanguage,
                    items: ['All', 'English', 'Mizo'],
                    onChanged: (val) {
                      setState(() => _selectedLanguage = val!);
                      bookController.filterByLanguage(val == 'All' ? '' : val!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: 'Sort By',
                    value: _sortBy,
                    items: [
                      'Newest',
                      'Oldest',
                      'Price: Low to High',
                      'Price: High to Low'
                    ],
                    onChanged: (val) {
                      setState(() => _sortBy = val!);
                      // Add sort logic if controller supports it
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Book Cards (Results)
            Expanded(
              child: Obx(() {
                final books = bookController.filteredBooks;
                if (books.isEmpty) {
                  return const Center(child: Text('No books found'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: books.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
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

  Widget _buildCategoryChip(
      Map<String, dynamic> cat, bool isSelected, BookController controller) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = cat['label']);
        controller.filterByGenre(cat['label'] == 'All' ? '' : cat['label']);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
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
              : Border.all(color: Theme.of(context).dividerColor.withAlpha(50)),
        ),
        child: Text(
          cat['label'],
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
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
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
