import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/book_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../../core/constants/app_constants.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final PageController _featuredController;
  int _featuredIndex = 0;
  final _searchController = TextEditingController();
  String _selectedCategory = '';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Fiction', 'icon': Icons.auto_stories},
    {'label': 'Non‑Fiction', 'icon': Icons.menu_book},
    {'label': 'Poetry', 'icon': Icons.library_books},
    {'label': 'History', 'icon': Icons.history_edu},
    {'label': 'Education', 'icon': Icons.school},
  ];

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.78);
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controllers are initialized via HomeBinding
    final bookController = Get.find<BookController>();
    final authController = Get.find<AuthController>();

    final userName = authController.currentUser?.name ?? 'Reader';

    return Scaffold(
      // Use Material 3 surface instead of deprecated background
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {
                // Focus search field
                FocusScope.of(context).requestFocus(FocusNode());
                showSnackSafe('Coming Soon', 'Search feature will be available soon');
              },
            ),
            IconButton(
              tooltip: 'Profile',
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
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Material(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Good day, $userName',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Discover new reads curated for you',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200),
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            PrimaryButton(label: 'Explore', onPressed: () => showSnackSafe('Explore', 'Explore feature coming soon')),
                                            const SizedBox(width: 10),
                                            TextButton(
                                              onPressed: () => showSnackSafe('For You', 'Curated picks are coming soon'),
                                              child: const Text('For You'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(50),
                                    child: Text(
                                      (userName.isNotEmpty ? userName[0] : 'U').toUpperCase(),
                                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Search bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: AppSearchBar(controller: _searchController, onFilter: () => _showFilterDialog(context, bookController)),
                        ),
                      ),

                      // Categories
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 64,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final selected = _selectedCategory == cat['label'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  label: Text(cat['label'],style: TextStyle(color: Colors.indigo.shade900,fontWeight: FontWeight.w600),),
                                  avatar: Icon(cat['icon'], size: 18),
                                  selected: selected,
                                  onSelected: (s) {
                                    setState(() {
                                      _selectedCategory = s ? cat['label'] as String : '';
                                    });
                                    bookController.filterByGenre(_selectedCategory);
                                  },
                                      selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(40),
                                      labelStyle: TextStyle(color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Featured carousel
                      if (bookController.featuredBooks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  'Featured',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ),
                              SizedBox(
                                height: 300,
                                child: PageView.builder(
                                  controller: _featuredController,
                                  itemCount: bookController.featuredBooks.length,
                                  onPageChanged: (p) => setState(() => _featuredIndex = p),
                                  itemBuilder: (context, index) {
                                    final book = bookController.featuredBooks[index];
                                    final active = index == _featuredIndex;
                                    return AnimatedPadding(
                                      duration: const Duration(milliseconds: 350),
                                      padding: EdgeInsets.only(left: 16, right: 8, bottom: active ? 4 : 18),
                                      child: _buildFeaturedCard(context, book, active),
                                    );
                                  },
                                ),
                              ),
                              // Dots
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: List.generate(
                                    bookController.featuredBooks.length,
                                    (i) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(right: 8),
                                      width: _featuredIndex == i ? 22 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _featuredIndex == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withAlpha(60),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // All Books grid (responsive)
                      SliverToBoxAdapter(child: _buildSectionHeader('Recommended for you', actionLabel: 'See All', onAction: () => showSnackSafe('See All', 'See all recommended'))),
                      SliverToBoxAdapter(child: _buildRecommendedSection(bookController)),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverLayoutBuilder(builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          int crossAxis = 2;
                          if (width > 1200) {
                            crossAxis = 4;
                          } else if (width > 800) {
                            crossAxis = 3;
                          } else if (width > 600) {
                            crossAxis = 2;
                          }

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxis,
                              childAspectRatio: 0.62,
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
                                  onTap: () => Get.toNamed(AppConstants.bookDetailRoute, arguments: book),
                                );
                              },
                              childCount: bookController.books.length,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                break;
              case 1:
                showSnackSafe('Coming Soon', 'My Library feature coming soon');
                break;
              case 2:
                showSnackSafe('Coming Soon', 'Wishlist feature coming soon');
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

  Widget _buildFeaturedCard(BuildContext context, dynamic book, bool active) {
    final radius = 16.0;
    return GestureDetector(
      onTap: () => Get.toNamed(AppConstants.bookDetailRoute, arguments: book),
      child: Material(
        elevation: active ? 12 : 6,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            book.coverImage != null
                ? Image.network(book.coverImage!, fit: BoxFit.cover)
                : Container(color: Theme.of(context).colorScheme.surface),
            // Scrim for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Theme.of(context).colorScheme.surface.withAlpha(220), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(book.authorName ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(200))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(BookController bookController) {
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: bookController.books.length.clamp(0, 8),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final b = bookController.books[index];
            return SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppConstants.bookDetailRoute, arguments: b),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: b.coverImage != null ? Image.network(b.coverImage!, fit: BoxFit.cover, width: double.infinity) : Container(color: Theme.of(context).colorScheme.surface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(b.title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _buildSectionHeader(String title, {String? actionLabel, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
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
