import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

typedef BottomNavTap = void Function(int index);

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final BottomNavTap onTap;
  final bool isAuthenticated;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAuthenticated = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassContainer(
          borderRadius: 28,
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            elevation: 0,
            backgroundColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              /// HOME
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),

              /// SEARCH
              const NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),

              /// LIBRARY (ONLY IF LOGGED IN)
              if (isAuthenticated)
                const NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories),
                  label: 'Library',
                ),

              /// PROFILE
              const NavigationDestination(
                icon: Icon(Icons.person_rounded),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
