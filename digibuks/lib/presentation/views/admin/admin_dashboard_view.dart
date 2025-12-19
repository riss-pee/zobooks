import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../controllers/admin_controller.dart';
// removed unused import: auth_controller
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.pending), text: 'Pending'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await adminController.loadStats();
            await adminController.loadUsers();
            await adminController.loadPendingBooks();
          },
          child: Obx(
            () => adminController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildOverviewTab(context, adminController),
                      _buildUsersTab(context, adminController),
                      _buildPendingTab(context, adminController),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Users',
                  '${controller.totalUsers}',
                  Icons.people,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Books',
                  '${controller.totalBooks}',
                  Icons.menu_book,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Revenue',
                  '₹${controller.totalRevenue.toInt()}',
                  Icons.account_balance_wallet,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Pending',
                  '${controller.pendingBooks.length}',
                  Icons.pending_actions,
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _buildActionCard(
                context,
                Icons.people,
                'Manage Users',
                () => Get.toNamed('/user-management'),
              ),
              _buildActionCard(
                context,
                Icons.pending_actions,
                'Content Moderation',
                () => Get.toNamed('/content-moderation'),
              ),
              _buildActionCard(context, Icons.analytics, 'Analytics', () {
                showSnackSafe('Analytics', 'Analytics feature coming soon');
              }),
              _buildActionCard(context, Icons.settings, 'Settings', () {
                showSnackSafe('Settings', 'Settings feature coming soon');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, AdminController controller) {
    if (controller.users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.users.length,
      itemBuilder: (context, index) {
        final user = controller.users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Text('Role: ${user.role}'),
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
                  controller.deleteUser(user.id);
                } else {
                  showSnackSafe('Edit', 'Edit feature coming soon');
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingTab(BuildContext context, AdminController controller) {
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
          child: ListTile(
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: AppTheme.successColor),
                  onPressed: () => controller.approveBook(book.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.errorColor),
                  onPressed: () => controller.rejectBook(book.id),
                ),
              ],
            ),
            onTap: () {
              Get.toNamed(AppConstants.bookDetailRoute, arguments: book);
            },
          ),
        );
      },
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

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          onTap();
          showSnackSafe('Coming Soon', '$label feature coming soon');
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
