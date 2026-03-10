import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

typedef BottomNavTap = void Function(int index);

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final BottomNavTap onTap;

  const CustomBottomNav(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassContainer(
          blur: 20,
          opacity: 0.15,
          borderRadius: 28,
          border: Border.all(
            color: Colors.white.withAlpha(77),
            width: 1.5,
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            elevation: 0,
            backgroundColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: 'Search'),
              NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories),
                  label: 'Library'),
              NavigationDestination(
                  icon: Icon(Icons.favorite_rounded),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Wishlist'),
              NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
