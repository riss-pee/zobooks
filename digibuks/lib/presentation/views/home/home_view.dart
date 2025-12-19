import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/book_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers are initialized via HomeBinding
    final bookController = Get.find<BookController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiBuks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              Get.snackbar('Coming Soon', 'Search feature will be available soon');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppConstants.profileRoute),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => bookController.loadBooks(),
        child: Obx(
          () => bookController.isLoading
              ? _buildLoadingView()
              : CustomScrollView(
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search books, authors, genres...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: () {
                                _showFilterDialog(context, bookController);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          onChanged: (value) => bookController.searchBooks(value),
                        ),
                      ),
                    ),
                    // Featured Books Section
                    if (bookController.featuredBooks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildSectionHeader('Featured Books'),
                      ),
                    if (bookController.featuredBooks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: bookController.featuredBooks.length,
                            itemBuilder: (context, index) {
                              final book = bookController.featuredBooks[index];
                              return Container(
                                width: 180,
                                margin: const EdgeInsets.only(right: 12),
                                child: BookCard(
                                  book: book,
                                  onTap: () => Get.toNamed(
                                    AppConstants.bookDetailRoute,
                                    arguments: book,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // All Books Section
                    SliverToBoxAdapter(
                      child: _buildSectionHeader('All Books'),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= bookController.books.length) {
                              return null;
                            }
                            final book = bookController.books[index];
                            return BookCard(
                              book: book,
                              onTap: () => Get.toNamed(
                                AppConstants.bookDetailRoute,
                                arguments: book,
                              ),
                            );
                          },
                          childCount: bookController.books.length,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Get.snackbar('Coming Soon', 'My Library feature coming soon');
              break;
            case 2:
              Get.snackbar('Coming Soon', 'Wishlist feature coming soon');
              break;
            case 3:
              Get.toNamed(AppConstants.profileRoute);
              break;
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LoadingShimmer(width: double.infinity, height: 50),
        const SizedBox(height: 16),
        ...List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BookCardShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, BookController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Books',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: controller.selectedLanguage.isEmpty,
                  onSelected: (selected) {
                    if (selected) controller.filterByLanguage('');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('English'),
                  selected: controller.selectedLanguage == AppConstants.languageEnglish,
                  onSelected: (selected) {
                    if (selected) controller.filterByLanguage(AppConstants.languageEnglish);
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Mizo'),
                  selected: controller.selectedLanguage == AppConstants.languageMizo,
                  onSelected: (selected) {
                    if (selected) controller.filterByLanguage(AppConstants.languageMizo);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.filterByGenre('');
                controller.filterByLanguage('');
                Navigator.pop(context);
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
