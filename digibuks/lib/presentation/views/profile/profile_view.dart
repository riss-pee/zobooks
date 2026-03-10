import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/glass_container.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F1113),
                    const Color(0xFF1A1C20),
                  ]
                : [
                    const Color(0xFFFFFBF0),
                    const Color(0xFFF7F0E0),
                  ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () => _showSettingsWindow(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Profile Header Glass
                if (authController.currentUser != null) ...[
                  _buildProfileHeader(context, authController.currentUser!),
                  const SizedBox(height: 24),
                  _buildLibrarySection(context),
                  const SizedBox(height: 16),
                  _buildAccountSection(context, authController.currentUser!),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, authController),
                ] else ...[
                  _buildGuestView(context),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          blur: 20,
          opacity: 0.1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_circle_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withAlpha(50),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to DigiBuks',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Login or create an account to view your profile, manage your books, and more.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppConstants.loginRoute),
                child: const Text('Login / Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      blur: 15,
      opacity: 0.1,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(50), width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withAlpha(50),
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Text(
                      user.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.name ?? 'User',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySection(BuildContext context) {
    return _buildGlassMenuSection(
      context,
      'Library',
      [
        _buildMenuItem(context, Icons.auto_stories_rounded, 'My Books', () {}),
        _buildMenuItem(context, Icons.favorite_rounded, 'Wishlist', () {}),
        _buildMenuItem(
            context, Icons.history_rounded, 'Reading History', () {}),
        _buildMenuItem(context, Icons.bookmark_rounded, 'Bookmarks', () {}),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, dynamic user) {
    return _buildGlassMenuSection(
      context,
      'Account',
      [
        _buildMenuItem(context, Icons.person_rounded, 'Edit Profile', () {}),
        _buildMenuItem(context, Icons.phone_rounded,
            'Phone: ${user.phone ?? "Not set"}', () {}),
      ],
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, AuthController authController) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context, authController),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: AppTheme.errorColor.withAlpha(100)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildGlassMenuSection(
      BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        GlassContainer(
          blur: 10,
          opacity: 0.1,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  void _showSettingsWindow(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(20),
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Material(
            color: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              blur: 40,
              opacity:
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.25,
              borderRadius: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildPopupItem(context, Icons.notifications_rounded,
                      'Notifications', () {}),
                  _buildPopupItem(
                      context, Icons.language_rounded, 'Language', () {}),
                  const SizedBox(height: 16),
                  _buildThemeToggleSection(context),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleSection(BuildContext context) {
    final controller = Get.find<ThemeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: [
                _buildThemeToggleOption(context, ThemeMode.light, 'Light',
                    Icons.light_mode_rounded, controller),
                const SizedBox(width: 8),
                _buildThemeToggleOption(context, ThemeMode.dark, 'Dark',
                    Icons.dark_mode_rounded, controller),
                const SizedBox(width: 8),
                _buildThemeToggleOption(context, ThemeMode.system, 'System',
                    Icons.brightness_auto_rounded, controller),
              ],
            )),
      ],
    );
  }

  Widget _buildThemeToggleOption(BuildContext context, ThemeMode mode,
      String label, IconData icon, ThemeController controller) {
    bool isSelected = controller.themeMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => controller.setThemeMode(mode),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white12,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[400]),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
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
              child: const Text('Cancel')),
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
