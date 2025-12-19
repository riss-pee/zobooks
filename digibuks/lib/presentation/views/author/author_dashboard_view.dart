import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/author_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AuthorDashboardView extends StatelessWidget {
  const AuthorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authorController = Get.put(AuthorController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Author Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => authorController.uploadBook(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => authorController.loadMyBooks(),
        child: Obx(
          () => authorController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      _buildStatsSection(context, authorController),
                      const SizedBox(height: 24),
                      // My Books Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Books',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: () => authorController.uploadBook(),
                            icon: const Icon(Icons.add),
                            label: const Text('Upload'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Books List
                      if (authorController.myBooks.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No books yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => authorController.uploadBook(),
                                icon: const Icon(Icons.add),
                                label: const Text('Upload Your First Book'),
                              ),
                            ],
                          ),
                        )
                      else
                        ...authorController.myBooks.map(
                          (book) => _buildBookListItem(context, book, authorController),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AuthorController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Books',
            '${controller.totalBooks}',
            Icons.menu_book,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Sales',
            '${controller.totalSales.toInt()}',
            Icons.shopping_cart,
            AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Revenue',
            '₹${controller.totalRevenue.toInt()}',
            Icons.account_balance_wallet,
            AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookListItem(
    BuildContext context,
    dynamic book,
    AuthorController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.menu_book,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${book.isPublished ? "Published" : "Draft"}'),
            if (book.price != null)
              Text('Price: ₹${book.price!.toStringAsFixed(0)}')
            else if (book.rentalPrice != null)
              Text('Rental: ₹${book.rentalPrice!.toStringAsFixed(0)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              controller.deleteBook(book.id);
            } else {
              Get.snackbar('Edit', 'Edit feature coming soon');
            }
          },
        ),
        onTap: () {
          Get.toNamed(AppConstants.bookDetailRoute, arguments: book);
        },
      ),
    );
  }
}
