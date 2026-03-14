import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'home_tab.dart';
import 'search_page.dart';
import '../library/library_view.dart';
import '../profile/profile_view.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final isAuthenticated = authController.isAuthenticated;
      
      final List<Widget> pages = [
        const HomeTab(),
        const SearchPage(),
        if (isAuthenticated) const LibraryView(),
        const ProfileView(),
      ];

      int activeIndex = _currentIndex;
      if (activeIndex >= pages.length) {
        activeIndex = pages.length - 1;
      }

      return Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: activeIndex,
          children: pages,
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: activeIndex,
          isAuthenticated: isAuthenticated,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      );
    });
  }
}
