import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_helper.dart';

import '../../widgets/glass_container.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize storage
    await StorageHelper.init();
    
    // Wait a bit for splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // Always navigate to home, allowing guest browsing
      Get.offAllNamed(AppConstants.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF0),
              Color(0xFFF7F0E0),
              Color(0xFFECE4D0),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Liquid Glass Logo Container
                GlassContainer(
                  width: 160,
                  height: 160,
                  blur: 20,
                  opacity: 0.1,
                  borderRadius: 40,
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'DigiBuks',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mizoram\'s Digital eBook Ecosystem',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 80),
                const CircularProgressIndicator(strokeWidth: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

