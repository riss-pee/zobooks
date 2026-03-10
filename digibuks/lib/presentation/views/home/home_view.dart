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
    return Obx(() {
      final isDark = Get.find<ThemeController>().isDarkMode;
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
          extendBody: true,
          backgroundColor: Colors.transparent,
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
    });
  }
}
