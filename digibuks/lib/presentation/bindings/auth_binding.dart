import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../core/network/api_client.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize dependencies
    final apiClient = Get.put(ApiClient());
    
    final authRemoteDataSource = Get.put(
      AuthRemoteDataSource(apiClient),
    );
    
    final authRepository = Get.put(AuthRepository(authRemoteDataSource));
    Get.put(AuthController(authRepository));
  }
}

