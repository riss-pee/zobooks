import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/snackbar_helper.dart';
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

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final user = authController.currentUser;

        /// NOT LOGGED IN
        if (user == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                blur: 20,
                opacity: 0.1,
                showShadow: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to Zo Reads',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Login or create an account to manage your books and profile.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(AppConstants.loginRoute),
                      child: const Text('Login / Sign Up'),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        /// MERGED PROFILE DATA
        final displayName = user.name ?? 'User';

        final displayEmail = user.email;

        final displayPhone = user.phone?.isNotEmpty == true
            ? user.phone!
            : 'Not set';

        final profileImage = user.profileImage;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              /// PROFILE HEADER
              GlassContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                blur: 25,
                opacity: 0.12,
                borderRadius: 32,
                showShadow: false,
                child: Column(
                  children: [
                    /// PROFILE IMAGE
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.05),
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage == null
                            ? Text(
                                displayName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      displayName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      displayEmail,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      displayPhone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 20),

                    /// ROLE BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ACCOUNT
              _buildGlassMenuSection(context, 'Account', [
                _buildMenuItem(
                  context,
                  Icons.person,
                  'Edit Profile',
                  () => Get.toNamed(AppConstants.editProfileRoute),
                ),
                _buildMenuItem(
                  context,
                  Icons.settings,
                  'Settings',
                  () => _showSettingsWindow(context),
                ),
              ]),

              const SizedBox(height: 16),

              /// LIBRARY
              _buildGlassMenuSection(context, 'Library', [
                _buildMenuItem(
                  context,
                  Icons.auto_stories,
                  'My Books',
                  () => showSnackSafe(
                      'Coming Soon', 'My books feature coming soon'),
                ),
                _buildMenuItem(
                  context,
                  Icons.bookmark,
                  'Bookmarks',
                  () => showSnackSafe(
                      'Coming Soon', 'Bookmarks feature coming soon'),
                ),
              ]),

              const SizedBox(height: 16),

              /// AUTHOR
              if (user.role == AppConstants.roleAuthor)
                _buildGlassMenuSection(context, 'Author', [
                  _buildMenuItem(
                    context,
                    Icons.dashboard,
                    'Author Dashboard',
                    () => Get.toNamed(AppConstants.authorDashboardRoute),
                  ),
                ]),

              /// ADMIN (RESTORED FROM OLD)
              if (user.role == AppConstants.roleAdmin)
                _buildGlassMenuSection(context, 'Admin', [
                  _buildMenuItem(
                    context,
                    Icons.admin_panel_settings,
                    'Admin Dashboard',
                    () => Get.toNamed(AppConstants.adminDashboardRoute),
                  ),
                ]),

              const SizedBox(height: 32),

              /// LOGOUT
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, authController),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGlassMenuSection(
      BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        GlassContainer(
          blur: 20,
          opacity: 0.12,
          borderRadius: 24,
          showShadow: false,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showSettingsWindow(BuildContext context) {
    final controller = Get.find<ThemeController>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Theme"),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: controller.themeMode,
                  onChanged: (val) { if (val != null) controller.setThemeMode(val); },
                  title: const Text("Light"),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: controller.themeMode,
                  onChanged: (val) { if (val != null) controller.setThemeMode(val); },
                  title: const Text("Dark"),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: controller.themeMode,
                  onChanged: (val) { if (val != null) controller.setThemeMode(val); },
                  title: const Text("System"),
                ),
              ],
            )),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
