import 'package:get/get.dart';
import '../../../data/models/grouped_books_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../core/utils/snackbar_helper.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  HomeController(this._repository);

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<GroupedBooksModel> groupedBooks = <GroupedBooksModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      print('HomeController.fetchBooks START');
      isLoading.value = true;
      error.value = '';
      
      final books = await _repository.getGroupedBooks();
      print('HomeController.fetchBooks SUCCESS - Got ${books.length} groups');
      
      groupedBooks.value = books;
    } catch (e, stackTrace) {
      print('HomeController.fetchBooks ERROR: $e');
      print('Stacktrace: $stackTrace');
      error.value = e.toString();
      showSnackSafe('Error', 'Failed to load books: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('HomeController.fetchBooks END');
    }
  }
}
