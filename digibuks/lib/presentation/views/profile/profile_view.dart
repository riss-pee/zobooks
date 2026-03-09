import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_helper.dart';
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
              showSnackSafe('Settings', 'Settings feature coming soon');
            },
          ),
        ],
      ),
      body: Obx(
        () {
          final user = authController.currentUser;
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary.withAlpha(127),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to DigiBuks',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login or create an account to view your profile, manage your books, and more.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(AppConstants.loginRoute),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Login / Sign Up'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header — use primary container surface for MD3
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? Text(
                                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  // initials on top of onPrimary background should use primary color
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary.withAlpha(0xE6),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary.withAlpha(0x33),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
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
                      () => showSnackSafe('Coming Soon', 'Edit profile feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.phone_outlined,
                      'Phone: ${user.phone ?? "Not set"}',
                      () => showSnackSafe('Coming Soon', 'Edit phone feature coming soon'),
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
                      () => showSnackSafe('Coming Soon', 'My books feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.favorite_outline,
                      'Wishlist',
                      () => showSnackSafe('Coming Soon', 'Wishlist feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.history,
                      'Reading History',
                      () => showSnackSafe('Coming Soon', 'Reading history feature coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.bookmark_outline,
                      'Bookmarks',
                      () => showSnackSafe('Coming Soon', 'Bookmarks feature coming soon'),
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
                        () => showSnackSafe('Coming Soon', 'Upload book feature coming soon'),
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
                      () => showSnackSafe('Coming Soon', 'Notifications settings coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.language,
                      'Language',
                      () => showSnackSafe('Coming Soon', 'Language settings coming soon'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.dark_mode_outlined,
                      'Theme',
                      () => showSnackSafe('Coming Soon', 'Theme settings coming soon'),
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
