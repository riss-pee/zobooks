import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/payment_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/reader_repository.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/home_repository.dart';
import '../views/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize ApiClient if not already initialized
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient());
    }
    
    // Initialize Auth dependencies if not already initialized
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(AuthRemoteDataSource(apiClient));
    }
    
    if (!Get.isRegistered<AuthRepository>()) {
      final authRemoteDataSource = Get.find<AuthRemoteDataSource>();
      Get.put(AuthRepository(authRemoteDataSource));
    }
    
    if (!Get.isRegistered<AuthController>()) {
      final authRepository = Get.find<AuthRepository>();
      Get.put(AuthController(authRepository));
    }
    
    // Initialize Home Data fetcher first so BookController can use it
    if (!Get.isRegistered<HomeRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(HomeRepository(apiClient));
    }

    // Initialize BookController if not already initialized
    if (!Get.isRegistered<BookController>()) {
      final homeRepo = Get.find<HomeRepository>();
      Get.put(BookController(homeRepo));
    }

    // Initialize PaymentRepository and PaymentController
    if (!Get.isRegistered<PaymentRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(PaymentRepository(apiClient));
    }

    if (!Get.isRegistered<PaymentController>()) {
      final paymentRepo = Get.find<PaymentRepository>();
      Get.put(PaymentController(paymentRepo));
    }

    // Initialize ReaderRepository
    if (!Get.isRegistered<ReaderRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(ReaderRepository(apiClient));
    }

    if (!Get.isRegistered<HomeController>()) {
      final homeRepository = Get.find<HomeRepository>();
      Get.put(HomeController(homeRepository));
    }
  }
}
