import 'package:get/get.dart';

import '../controllers/reader_controller.dart';
import '../../data/repositories/reader_repository.dart';
import '../../core/network/api_client.dart';

class ReaderBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ApiClient exists
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient());
    }

    // Ensure ReaderRepository is available
    if (!Get.isRegistered<ReaderRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(ReaderRepository(apiClient));
    }

    // ReaderController should be created fresh (uses Get.arguments)
    Get.put(
      ReaderController(
        Get.find<ReaderRepository>(),
      ),
    );
  }
}
