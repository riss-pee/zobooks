import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/payment_controller.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/reader_repository.dart';

import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../core/network/api_client.dart';

import '../views/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient());
    }

    // Auth Remote Source
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(AuthRemoteDataSource(apiClient));
    }

    // Auth Repository
    if (!Get.isRegistered<AuthRepository>()) {
      final authRemoteDataSource = Get.find<AuthRemoteDataSource>();
      Get.put(AuthRepository(authRemoteDataSource));
    }

    // Auth Controller
    if (!Get.isRegistered<AuthController>()) {
      final authRepository = Get.find<AuthRepository>();
      Get.put(AuthController(authRepository));
    }

    // Home Repository (needed for books)
    if (!Get.isRegistered<HomeRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(HomeRepository(apiClient));
    }

    // Book Controller
    if (!Get.isRegistered<BookController>()) {
      final homeRepo = Get.find<HomeRepository>();
      Get.put(BookController(homeRepo));
    }

    // Payment Repository
    if (!Get.isRegistered<PaymentRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(PaymentRepository(apiClient));
    }

    // Payment Controller
    if (!Get.isRegistered<PaymentController>()) {
      final paymentRepo = Get.find<PaymentRepository>();
      Get.put(PaymentController(paymentRepo));
    }

    // Reader Repository
    if (!Get.isRegistered<ReaderRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(ReaderRepository(apiClient));
    }

    // Home Controller
    if (!Get.isRegistered<HomeController>()) {
      final homeRepository = Get.find<HomeRepository>();
      Get.put(HomeController(homeRepository));
    }
  }
}
