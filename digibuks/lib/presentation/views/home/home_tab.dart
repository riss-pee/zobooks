import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/book_controller.dart';
import '../../controllers/auth_controller.dart';

import '../../../data/models/grouped_books_model.dart';
import '../../../data/models/book_model.dart';

import 'home_controller.dart';

import '../../widgets/book_card.dart';
import '../../widgets/loading_shimmer.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_helper.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final PageController _featuredController;

  int _featuredIndex = 0;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();

    final userName = authController.currentUser?.name ?? 'Reader';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      /// HEADER
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 28,
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'U',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      /// TRENDING BOOKS
                      Obx(() {
                        if (homeController.trendingBooks.isEmpty) {
                          return const SliverToBoxAdapter(
                              child: SizedBox.shrink());
                        }

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child:
                                  _buildSectionHeader(context, 'Trending Now'),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 260,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      homeController.trendingBooks.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 16),
                                  itemBuilder: (context, index) {
                                    final book =
                                        homeController.trendingBooks[index];

                                    return SizedBox(
                                      width: 120,
                                      child:
                                          _buildBookSummaryCard(context, book),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      /// FEATURED BOOKS
                      if (bookController.featuredBooks.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildSectionHeader(context, 'Featured Books'),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _featuredController,
                              itemCount: bookController.featuredBooks.length,
                              onPageChanged: (p) =>
                                  setState(() => _featuredIndex = p),
                              itemBuilder: (context, index) {
                                final book =
                                    bookController.featuredBooks[index];

                                return _buildFeaturedCard(context, book);
                              },
                            ),
                          ),
                        ),
                      ],

                      /// CATEGORY GROUPS
                      ...homeController.groupedBooks.map((group) {
                        if (group.books.isEmpty) {
                          return const SliverToBoxAdapter(
                              child: SizedBox.shrink());
                        }

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child:
                                  _buildSectionHeader(context, group.category),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 260,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: group.books.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 16),
                                  itemBuilder: (context, index) {
                                    final book = group.books[index];

                                    return SizedBox(
                                      width: 120,
                                      child:
                                          _buildBookSummaryCard(context, book),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),

                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
      onTap: () {
        final mockBook = BookModel(
          id: book.id,
          title: book.title,
          coverImage: book.coverUrl,
          authorName: book.authors.isNotEmpty ? book.authors.first : 'Unknown',
          authorId: 'unknown',
          price: book.price,
          fileType: 'pdf',
          language: book.language ?? 'english',
          type: book.isFree
              ? AppConstants.bookTypeFree
              : AppConstants.bookTypePurchase,
        );

        Get.toNamed(AppConstants.bookDetailRoute, arguments: mockBook);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          book.coverUrl ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBookSummaryCard(BuildContext context, dynamic book) {
    return GestureDetector(
      onTap: () {
        final mockBook = BookModel(
          id: book.id,
          title: book.title,
          coverImage: book.coverUrl,
          authorName: book.authors.isNotEmpty ? book.authors.first : 'Unknown',
          authorId: 'unknown',
          price: book.price,
          fileType: 'pdf',
          language: book.language ?? 'english',
          type: book.isFree
              ? AppConstants.bookTypeFree
              : AppConstants.bookTypePurchase,
        );

        Get.toNamed(AppConstants.bookDetailRoute, arguments: mockBook);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                book.coverUrl ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            book.authors.isNotEmpty ? book.authors.first : 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LoadingShimmer(width: double.infinity, height: 60),
        const SizedBox(height: 24),
        LoadingShimmer(width: double.infinity, height: 250),
      ],
    );
  }
}
