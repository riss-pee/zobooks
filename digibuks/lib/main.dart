import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/storage_helper.dart';
import 'presentation/routes/app_routes.dart';
import 'core/constants/app_constants.dart';

import 'presentation/controllers/theme_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/book_controller.dart';
import 'presentation/controllers/payment_controller.dart';

import 'core/network/api_client.dart';

import 'data/datasources/remote/auth_remote_datasource.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/home_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/reader_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageHelper.init();

  // Global controllers
  Get.put(ThemeController());

  // Core API client
  final apiClient = Get.put(ApiClient());

  // Auth setup
  final authRemoteDataSource = Get.put(AuthRemoteDataSource(apiClient));
  final authRepository = Get.put(AuthRepository(authRemoteDataSource));
  Get.put(AuthController(authRepository));

  // Home / Books
  final homeRepository = Get.put(HomeRepository(apiClient));
  Get.put(BookController(homeRepository));

  // Payment
  final paymentRepository = Get.put(PaymentRepository(apiClient));
  Get.put(PaymentController(paymentRepository));

  // Reader
  Get.put(ReaderRepository(apiClient));

  runApp(const DigiBuksApp());
}

class DigiBuksApp extends StatelessWidget {
  const DigiBuksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'DigiBuks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppConstants.splashRoute,
        getPages: AppRoutes.routes,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
