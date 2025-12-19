import 'package:flutter/material.dart';
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
import '../views/admin/user_management_view.dart';
import '../views/admin/content_moderation_view.dart';
import '../views/author/upload_book_view.dart';
import '../views/author/analytics_view.dart';
import '../views/payment/payment_view.dart';
import '../../data/models/book_model.dart';
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
    GetPage(
      name: AppConstants.uploadBookRoute,
      page: () => const UploadBookView(),
    ),
    GetPage(
      name: AppConstants.authorAnalyticsRoute,
      page: () => const AnalyticsView(),
    ),
    GetPage(
      name: AppConstants.userManagementRoute,
      page: () => const UserManagementView(),
    ),
    GetPage(
      name: AppConstants.contentModerationRoute,
      page: () => const ContentModerationView(),
    ),
    GetPage(
      name: AppConstants.paymentRoute,
      page: () {
        final args = Get.arguments;
        if (args is Map<String, dynamic> && args['book'] != null) {
          return PaymentView(
            book: args['book'] as BookModel,
            paymentType: args['type'] as String? ?? 'purchase',
            rentalDays: args['rentalDays'] as int?,
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Payment')),
          body: const Center(child: Text('Invalid payment request')),
        );
      },
    ),
  ];
}

