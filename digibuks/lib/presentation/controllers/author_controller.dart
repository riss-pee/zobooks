import 'package:get/get.dart';
import '../../data/models/book_model.dart';
import '../../core/utils/logger.dart';

class AuthorController extends GetxController {
  final _myBooks = <BookModel>[].obs;
  final _isLoading = false.obs;
  final _totalSales = 0.0.obs;
  final _totalRevenue = 0.0.obs;
  final _totalBooks = 0.obs;

  List<BookModel> get myBooks => _myBooks;
  bool get isLoading => _isLoading.value;
  double get totalSales => _totalSales.value;
  double get totalRevenue => _totalRevenue.value;
  int get totalBooks => _totalBooks.value;

  @override
  void onInit() {
    super.onInit();
    loadMyBooks();
    loadStats();
  }

  Future<void> loadMyBooks() async {
    try {
      _isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock books for demo
      _myBooks.value = List.generate(5, (index) {
        return BookModel(
          id: 'my_book_$index',
          title: 'My Book ${index + 1}',
          description: 'Description of my book',
          authorId: 'current_author',
          authorName: 'Me',
          fileType: 'pdf',
          language: 'english',
          type: index % 2 == 0 ? 'purchase' : 'rental',
          price: index % 2 == 0 ? 299.0 : null,
          rentalPrice: index % 2 == 1 ? 99.0 : null,
          rentalDays: index % 2 == 1 ? 7 : null,
          isPublished: index < 3,
          rating: 4.0 + (index * 0.2),
          reviewCount: index * 10,
          pageCount: 200 + (index * 50),
          createdAt: DateTime.now().subtract(Duration(days: index * 30)),
          updatedAt: DateTime.now().subtract(Duration(days: index * 5)),
        );
      });
      _totalBooks.value = _myBooks.length;
    } catch (e) {
      AppLogger.e('Error loading my books', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _totalSales.value = 1250.0;
      _totalRevenue.value = 875.0; // After commission
    } catch (e) {
      AppLogger.e('Error loading stats', e);
    }
  }

  Future<void> uploadBook() async {
    Get.snackbar('Upload', 'Book upload feature coming soon');
  }

  Future<void> deleteBook(String bookId) async {
    _myBooks.removeWhere((book) => book.id == bookId);
    Get.snackbar('Deleted', 'Book deleted successfully');
  }
}

