import 'package:get/get.dart';
import '../controllers/reader_controller.dart';
import '../../data/repositories/reader_repository.dart';
import '../../core/network/api_client.dart';

class ReaderBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ReaderRepository is available
    if (!Get.isRegistered<ReaderRepository>()) {
      final apiClient = Get.find<ApiClient>();
      Get.put(ReaderRepository(apiClient));
    }
    // ReaderController is created fresh each time (needs Get.arguments for book)
    Get.put(ReaderController(Get.find<ReaderRepository>()));
  }
}
