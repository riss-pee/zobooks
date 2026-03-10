import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';
import 'home_controller.dart';
import '../../widgets/book_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/search_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_helper.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final PageController _featuredController;
  final _searchController = TextEditingController();
  int _featuredIndex = 0;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controllers
    final bookController = Get.find<BookController>();
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();
    final userName = authController.currentUser?.name ?? 'Reader';

    return Scaffold(
      backgroundColor: Colors.transparent, // Let parent or decoration handle it
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            bookController.loadBooks();
            homeController.fetchBooks();
          },
          child: Obx(
            () => homeController.isLoading.value
                ? _buildLoadingView()
                : CustomScrollView(
                    slivers: [
                      // 1. Header & Search
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Glassy Greeting Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(150),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 28,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withAlpha(30),
                                      child: Text(
                                        (userName.isNotEmpty
                                                ? userName[0]
                                                : 'U')
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Search Bar
                              AppSearchBar(
                                controller: _searchController,
                                onFilter: () =>
                                    _showFilterDialog(context, bookController),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // 3. Featured Section
                      if (bookController.featuredBooks.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text(
                              'Trending Now',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 280,
                            child: PageView.builder(
                              controller: _featuredController,
                              itemCount: bookController.featuredBooks.length,
                              onPageChanged: (p) =>
                                  setState(() => _featuredIndex = p),
                              itemBuilder: (context, index) {
                                final book =
                                    bookController.featuredBooks[index];
                                final active = index == _featuredIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: active ? 0 : 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: active
                                        ? [
                                            BoxShadow(
                                                color:
                                                    Colors.black.withAlpha(50),
                                                blurRadius: 15,
                                                offset: const Offset(0, 10))
                                          ]
                                        : [],
                                  ),
                                  child: _buildFeaturedCard(context, book),
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],

                      // 4. Dynamic Categories from API
                      ...homeController.groupedBooks.map((group) {
                        if (group.books.isEmpty)
                          return const SliverToBoxAdapter(
                              child: SizedBox.shrink());

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _buildSectionHeader(
                                  context, group.category, () {}),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 340,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: group.books.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 16),
                                  itemBuilder: (context, index) {
                                    final book = group.books[index];
                                    // Create an interim BookModel to reuse BookCard formatting,
                                    // or properly update BookCard.
                                    // For simplicity, converting BookSummaryModel to dynamic to pass to Get arguments or UI correctly
                                    return SizedBox(
                                      width: 150,
                                      child:
                                          _buildBookSummaryCard(context, book),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 24)),
                          ],
                        );
                      }).toList(),

                      // Bottom padding for safer scrolling above navbar
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildFeaturedCard(BuildContext context, dynamic book) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppConstants.bookDetailRoute, arguments: book),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: book.coverImage != null
                ? Image.network(
                    book.coverImage!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Center(
                      child: Icon(Icons.menu_book,
                          size: 50,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(20),
                  Colors.black.withAlpha(200),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Text Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Featured',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.authorName ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookSummaryCard(BuildContext context, dynamic book) {
    return GestureDetector(
      onTap: () {
        // Create mock full book argument from API until BookDetail handles ID or SummaryModel
        final mockBookArg = {
          'id': book.id,
          'title': book.title,
          'coverImage': book.coverUrl,
          'authorName':
              book.authors.isNotEmpty ? book.authors.first : 'Unknown',
          'price': book.price,
          'isFree': book.isFree,
        };
        Get.toNamed(AppConstants.bookDetailRoute, arguments: mockBookArg);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : Center(
                        child: Icon(
                          Icons.menu_book,
                          size: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withAlpha(100),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Original layout with Title & Author
          Text(
            book.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.authors.isNotEmpty ? book.authors.first : 'Unknown',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Price Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: book.isFree
                      ? Colors.green.withAlpha(20)
                      : Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  book.isFree ? 'Free' : '₹${book.price}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: book.isFree
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: () =>
                showSnackSafe('Coming Soon', 'See all coming soon'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LoadingShimmer(width: double.infinity, height: 60),
        const SizedBox(height: 24),
        LoadingShimmer(width: double.infinity, height: 30),
        const SizedBox(height: 24),
        LoadingShimmer(width: double.infinity, height: 250),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(4, (index) => const BookCardShimmer()),
        )
      ],
    );
  }

  void _showFilterDialog(BuildContext context, BookController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter Books',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Text('Language',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _buildFilterChip(
                    context, 'All', controller.selectedLanguage.isEmpty, () {
                  controller.filterByLanguage('');
                  Navigator.pop(context);
                }),
                _buildFilterChip(context, 'English',
                    controller.selectedLanguage == AppConstants.languageEnglish,
                    () {
                  controller.filterByLanguage(AppConstants.languageEnglish);
                  Navigator.pop(context);
                }),
                _buildFilterChip(context, 'Mizo',
                    controller.selectedLanguage == AppConstants.languageMizo,
                    () {
                  controller.filterByLanguage(AppConstants.languageMizo);
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.filterByGenre('');
                  controller.filterByLanguage('');
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 0,
                ),
                child: const Text('Clear All Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected ? Colors.transparent : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
