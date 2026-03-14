import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/glass_container.dart';
import '../../../core/utils/snackbar_helper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(
          () {
            final user = authController.currentUser;
            final profile = authController.userProfile;
            
            if (user == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    blur: 20,
                    opacity: 0.1,
                    showShadow: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_circle_rounded,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Zo Reads',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Login or create an account to view your profile, manage your books, and more.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
                              ),
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

            final displayName = profile?.username.isNotEmpty == true 
                 ? profile!.username 
                 : (user.name ?? 'User');
            final displayEmail = profile?.email.isNotEmpty == true 
                 ? profile!.email 
                 : user.email;
            final displayPhone = profile?.phone?.isNotEmpty == true
                 ? profile!.phone!
                 : (user.phone ?? 'Not set');
            final profileImage = profile?.profileImage ?? user.profileImage;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Profile Header Glass
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    blur: 25,
                    opacity: 0.12,
                    borderRadius: 32,
                    showShadow: false,
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), 
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                            backgroundImage: profileImage != null
                                ? NetworkImage(profileImage)
                                : null,
                            child: profileImage == null
                                ? Text(
                                    displayName.isNotEmpty == true
                                        ? displayName.substring(0, 1).toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayEmail,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayPhone,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.role.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Items in Glass Containers
                  _buildGlassMenuSection(
                    context,
                    'Account',
                    [
                      _buildMenuItem(
                        context,
                        Icons.person_rounded,
                        'Edit Profile',
                        () => Get.toNamed(AppConstants.editProfileRoute),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.settings_rounded,
                        'Settings',
                        () => _showSettingsWindow(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildGlassMenuSection(
                    context,
                    'Library',
                    [
                      _buildMenuItem(
                        context,
                        Icons.auto_stories_rounded,
                        'My Books',
                        () => showSnackSafe(
                            'Coming Soon', 'My books feature coming soon'),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.bookmark_rounded,
                        'Bookmarks',
                        () => showSnackSafe(
                            'Coming Soon', 'Bookmarks feature coming soon'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (user.role == AppConstants.roleAuthor) ...[
                    _buildGlassMenuSection(
                      context,
                      'Author',
                      [
                        _buildMenuItem(
                          context,
                          Icons.dashboard_rounded,
                          'Author Dashboard',
                          () => Get.toNamed(AppConstants.authorDashboardRoute),
                        ),
                        _buildMenuItem(
                          context,
                          Icons.add_circle_rounded,
                          'Upload Book',
                          () => showSnackSafe(
                              'Coming Soon', 'Upload book feature coming soon'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showLogoutDialog(context, authController),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(
                            color: AppTheme.errorColor.withOpacity(0.3),
                            width: 1.5),
                        backgroundColor: AppTheme.errorColor.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
    );
  }

  Widget _buildGlassMenuSection(
      BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
        ),
        GlassContainer(
          blur: 20,
          opacity: 0.12,
          borderRadius: 24,
          showShadow: false,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, 
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded, 
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), 
            size: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
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
              showShadow: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
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
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
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
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
                : Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2) 
                    : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onSurface 
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onSurface 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
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
