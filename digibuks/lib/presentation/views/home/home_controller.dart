import 'package:get/get.dart';
import '../../../data/models/grouped_books_model.dart';
import '../../../data/models/trending_book_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../core/utils/snackbar_helper.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  HomeController(this._repository);

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<GroupedBooksModel> groupedBooks = <GroupedBooksModel>[].obs;
  final RxList<TrendingBookModel> trendingBooks = <TrendingBookModel>[].obs;

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
      
      final results = await Future.wait([
        _repository.getGroupedBooks(),
        _repository.getTrendingBooks(),
      ]);
      
      final books = results[0] as List<GroupedBooksModel>;
      final trending = results[1] as List<TrendingBookModel>;

      print('HomeController.fetchBooks SUCCESS - Got ${books.length} groups, ${trending.length} trending');
      
      groupedBooks.value = books;
      trendingBooks.value = trending;
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
