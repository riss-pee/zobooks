import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_helper.dart';
import 'presentation/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'presentation/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageHelper.init();
  
  // Initialize Global Controllers
  Get.put(ThemeController());
  
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
