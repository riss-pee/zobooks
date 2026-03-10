import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/payment_controller.dart';
import '../../data/repositories/auth_repository.dart';
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
    
    // Initialize BookController if not already initialized
    if (!Get.isRegistered<BookController>()) {
      Get.put(BookController());
    }

    // Initialize PaymentController if not already initialized
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }

    // Initialize Home Data fetcher
    if (!Get.isRegistered<HomeRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(HomeRepository(apiClient));
    }

    if (!Get.isRegistered<HomeController>()) {
      final homeRepository = Get.find<HomeRepository>();
      Get.put(HomeController(homeRepository));
    }
  }
}
