import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/book_model.dart';
import '../../data/models/sample_books.dart';
import '../../core/utils/logger.dart';

class BookController extends GetxController {
  // Observable state
  final _books = <BookModel>[].obs;
  final _featuredBooks = <BookModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedGenre = ''.obs;
  final _selectedLanguage = ''.obs;
  final _isLoading = false.obs;
  final _wishlist = <String>[].obs; // Book IDs

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  String get searchQuery => _searchQuery.value;
  String get selectedGenre => _selectedGenre.value;
  String get selectedLanguage => _selectedLanguage.value;
  bool get isLoading => _isLoading.value;
  List<String> get wishlist => _wishlist;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
    loadFeaturedBooks();
    loadWishlist();
  }

  Future<void> loadBooks() async {
    try {
      _isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Load sample books with realistic data
      _books.value = SampleBooks.getBooks();
      AppLogger.i('Books loaded: ${_books.length}');
    } catch (e) {
      AppLogger.e('Error loading books', e);
      showSnackSafe('Error', 'Failed to load books');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadFeaturedBooks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _featuredBooks.value = _books.take(5).toList();
    } catch (e) {
      AppLogger.e('Error loading featured books', e);
    }
  }

  void searchBooks(String query) {
    _searchQuery.value = query;
    // In real app, this would filter or search via API
  }

  void filterByGenre(String genre) {
    _selectedGenre.value = genre;
    // In real app, this would filter via API
  }

  void filterByLanguage(String language) {
    _selectedLanguage.value = language;
    // In real app, this would filter via API
  }

  void toggleWishlist(String bookId) {
    if (_wishlist.contains(bookId)) {
      _wishlist.remove(bookId);
      showSnackSafe(
        'Removed',
        'Book removed from wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      _wishlist.add(bookId);
      showSnackSafe(
        'Added',
        'Book added to wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool isInWishlist(String bookId) {
    return _wishlist.contains(bookId);
  }

  void loadWishlist() {
    // Load from storage in real app
    _wishlist.value = [];
  }

}

