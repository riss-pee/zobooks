import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use find or putIfAbsent to handle case where controller might not be initialized
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.snackbar('Settings', 'Settings feature coming soon');
            },
          ),
        ],
      ),
      body: Obx(
        () {
          final user = authController.currentUser;
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? Text(
                                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu Items
                _buildMenuSection(
                  context,
                  'Account',
                  [
                    _buildMenuItem(
                      context,
                      Icons.person_outline,
                      'Edit Profile',
                      () => Get.snackbar('Coming Soon', 'Edit profile feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.phone_outlined,
                      'Phone: ${user.phone ?? "Not set"}',
                      () => Get.snackbar('Coming Soon', 'Edit phone feature coming soon'),
                    ),
                  ],
                ),
                _buildMenuSection(
                  context,
                  'Library',
                  [
                    _buildMenuItem(
                      context,
                      Icons.library_books,
                      'My Books',
                      () => Get.snackbar('Coming Soon', 'My books feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.favorite_outline,
                      'Wishlist',
                      () => Get.snackbar('Coming Soon', 'Wishlist feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.history,
                      'Reading History',
                      () => Get.snackbar('Coming Soon', 'Reading history feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.bookmark_outline,
                      'Bookmarks',
                      () => Get.snackbar('Coming Soon', 'Bookmarks feature coming soon'),
                    ),
                  ],
                ),
                if (user.role == AppConstants.roleAuthor)
                  _buildMenuSection(
                    context,
                    'Author',
                    [
                      _buildMenuItem(
                        context,
                        Icons.dashboard,
                        'Author Dashboard',
                        () => Get.toNamed(AppConstants.authorDashboardRoute),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.add_circle_outline,
                        'Upload Book',
                        () => Get.snackbar('Coming Soon', 'Upload book feature coming soon'),
                      ),
                    ],
                  ),
                if (user.role == AppConstants.roleAdmin)
                  _buildMenuSection(
                    context,
                    'Admin',
                    [
                      _buildMenuItem(
                        context,
                        Icons.admin_panel_settings,
                        'Admin Dashboard',
                        () => Get.toNamed(AppConstants.adminDashboardRoute),
                      ),
                    ],
                  ),
                _buildMenuSection(
                  context,
                  'Settings',
                  [
                    _buildMenuItem(
                      context,
                      Icons.notifications_outlined,
                      'Notifications',
                      () => Get.snackbar('Coming Soon', 'Notifications settings coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.language,
                      'Language',
                      () => Get.snackbar('Coming Soon', 'Language settings coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.dark_mode_outlined,
                      'Theme',
                      () => Get.snackbar('Coming Soon', 'Theme settings coming soon'),
                    ),
                  ],
                ),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, authController),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
