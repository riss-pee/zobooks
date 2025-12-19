import 'package:flutter/material.dart';

typedef BottomNavTap = void Function(int index);

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final BottomNavTap onTap;

  const CustomBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      elevation: 8,
      backgroundColor: colorScheme.surface,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      // Indicator color will use primary by default; enforce a softer indicator
      // via NavigationBarTheme if needed in the global theme
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Library'),
        NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Wishlist'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
