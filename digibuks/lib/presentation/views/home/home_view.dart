import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../controllers/theme_controller.dart';
import 'home_tab.dart';
import 'search_page.dart';
import '../library/library_view.dart';
import '../wishlist/wishlist_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const SearchPage(),
    const LibraryView(),
    const WishlistView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F5F5),
            Color(0xFFEEEEEE),
          ],
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        // We don't set an AppBar here because each child page manages its own AppBar.
        // We don't set backgroundColor here, children manage it.
        
        // Use IndexedStack to preserve state of each tab
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
