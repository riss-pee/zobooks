import 'package:get/get.dart';
import '../../../data/models/grouped_books_model.dart';
import '../../../data/models/trending_book_model.dart';
import '../../../data/models/book_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../core/utils/snackbar_helper.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  HomeController(this._repository);

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<GroupedBooksModel> groupedBooks = <GroupedBooksModel>[].obs;
  final RxList<TrendingBookModel> trendingBooks = <TrendingBookModel>[].obs;
  final RxList<BookModel> latestPublishedBooks = <BookModel>[].obs;

  // For refresh-on-focus: track last fetch time to avoid excessive API calls
  DateTime? _lastFetchTime;
  static const Duration _refreshThreshold = Duration(minutes: 5);

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
        _repository.getLatestPublishedBooks(limit: 10),
      ]);

      final books = results[0] as List<GroupedBooksModel>;
      final trending = results[1] as List<TrendingBookModel>;
      final latest = results[2] as List<BookModel>;

      print(
          'HomeController.fetchBooks SUCCESS - Got ${books.length} groups, ${trending.length} trending, ${latest.length} latest');

      groupedBooks.value = books;
      trendingBooks.value = trending;
      latestPublishedBooks.value = latest;
      _lastFetchTime = DateTime.now();
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

  /// Refresh books if enough time has passed since last fetch
  /// Prevents excessive API calls when user returns to app frequently
  Future<void> refreshIfNeeded() async {
    if (_lastFetchTime == null) {
      await fetchBooks();
      return;
    }

    final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
    if (timeSinceLastFetch >= _refreshThreshold) {
      print('HomeController: Refreshing due to time threshold exceeded');
      await fetchBooks();
    } else {
      print(
          'HomeController: Skipping refresh (fetched ${timeSinceLastFetch.inSeconds}s ago)');
    }
  }
}
