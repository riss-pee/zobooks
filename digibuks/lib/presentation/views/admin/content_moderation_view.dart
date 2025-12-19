import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../../core/theme/app_theme.dart';
// removed unused import: app_constants

class ContentModerationView extends StatelessWidget {
  const ContentModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Moderation'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending), text: 'Pending Books'),
              Tab(icon: Icon(Icons.flag), text: 'Reported Content'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => adminController.loadPendingBooks(),
          child: Obx(
            () => TabBarView(
              children: [
                _buildPendingBooksTab(context, adminController),
                _buildReportedContentTab(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingBooksTab(BuildContext context, AdminController controller) {
    if (controller.pendingBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending books',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.pendingBooks.length,
      itemBuilder: (context, index) {
        final book = controller.pendingBooks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(book.title),
            subtitle: Text('By ${book.authorName ?? "Unknown"}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book.description != null) ...[
                      Text(
                        'Description:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(book.description!),
                      const SizedBox(height: 16),
                    ],
                    Text('Language: ${book.language}'),
                    Text('File Type: ${book.fileType.toUpperCase()}'),
                    if (book.price != null) Text('Price: ₹${book.price!.toStringAsFixed(0)}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => controller.rejectBook(book.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => controller.approveBook(book.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportedContentTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No reported content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Reported books and reviews will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

