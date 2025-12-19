import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';
import '../views/books/book_detail_view.dart';
import '../views/reader/reader_view.dart';
import '../views/profile/profile_view.dart';
import '../views/author/author_dashboard_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../../core/constants/app_constants.dart';

class AppRoutes {
  static final List<GetPage> routes = [
    GetPage(
      name: AppConstants.splashRoute,
      page: () => const HomeView(), // TODO: Create SplashView
    ),
    GetPage(
      name: AppConstants.loginRoute,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppConstants.registerRoute,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: AppConstants.homeRoute,
      page: () => const HomeView(),
    ),
    GetPage(
      name: AppConstants.bookDetailRoute,
      page: () => const BookDetailView(),
    ),
    GetPage(
      name: AppConstants.readerRoute,
      page: () => const ReaderView(),
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

