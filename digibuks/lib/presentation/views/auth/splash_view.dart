import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_helper.dart';

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
              Color(0xFFF5F5F5),
              Color(0xFFEEEEEE),
              Color(0xFFE0E0E0),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ZoReads Logo
                Image.asset(
                  'assets/images/ZoReads_logo.png',
                  width: 264,
                  height: 264,
                  fit: BoxFit.contain,
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
