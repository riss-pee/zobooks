import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/splash_view.dart';
import '../views/home/home_view.dart';
import '../views/books/book_detail_view.dart';
import '../views/reader/reader_view.dart';
import '../views/profile/profile_view.dart';
import '../views/author/author_dashboard_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/reader_binding.dart';
import '../../core/constants/app_constants.dart';

class AppRoutes {
  static final List<GetPage> routes = [
    GetPage(
      name: AppConstants.splashRoute,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppConstants.loginRoute,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppConstants.registerRoute,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppConstants.homeRoute,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppConstants.bookDetailRoute,
      page: () => const BookDetailView(),
    ),
    GetPage(
      name: AppConstants.readerRoute,
      page: () => const ReaderView(),
      binding: ReaderBinding(),
    ),
    GetPage(
      name: AppConstants.profileRoute,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: AppConstants.authorDashboardRoute,
      page: () => const AuthorDashboardView(),
    ),
    GetPage(
      name: AppConstants.adminDashboardRoute,
      page: () => const AdminDashboardView(),
    ),
  ];
}

