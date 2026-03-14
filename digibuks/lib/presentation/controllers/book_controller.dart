import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/book_model.dart';
import '../../data/models/category_model.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/reader_repository.dart';

class BookController extends GetxController {
  final HomeRepository _repository;

  BookController(this._repository);

  // Observable state
  final _books = <BookModel>[].obs;
  final _featuredBooks = <BookModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedGenre = ''.obs;
  final _selectedLanguage = ''.obs;
  final _isLoading = false.obs;
  final _wishlist = <String>[].obs; // Book IDs
  
  final Rx<BookModel?> currentBook = Rx<BookModel?>(null);
  final RxBool isLoadingDetails = false.obs;

  final _currentPage = 1.obs;
  final _hasMoreBooks = true.obs;
  final _isLoadingMore = false.obs;

  final _categories = <CategoryModel>[].obs;
  final _isCategoriesLoading = false.obs;

  final _myLibraryBooks = <BookModel>[].obs;
  final _isLoadingLibrary = false.obs;

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  String get searchQuery => _searchQuery.value;
  String get selectedGenre => _selectedGenre.value;
  String get selectedLanguage => _selectedLanguage.value;
  bool get isLoading => _isLoading.value;
  List<String> get wishlist => _wishlist;

  List<CategoryModel> get categories => _categories;
  bool get isCategoriesLoading => _isCategoriesLoading.value;

  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMoreBooks => _hasMoreBooks.value;

  List<BookModel> get myLibraryBooks => _myLibraryBooks;
  bool get isLoadingLibrary => _isLoadingLibrary.value;

  List<BookModel> get filteredBooks => _books;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
    loadFeaturedBooks();
    loadWishlist();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      _isCategoriesLoading.value = true;
      _categories.value = await _repository.getCategories();
    } catch (e) {
      AppLogger.e('Error loading categories', e);
    } finally {
      _isCategoriesLoading.value = false;
    }
  }

  Future<void> loadBooks() async {
    try {
      _isLoading.value = true;
      await searchBooksByApi('');
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
      // Just take top 5 from existing books for now
      _featuredBooks.value = _books.take(5).toList();
    } catch (e) {
      AppLogger.e('Error loading featured books', e);
    }
  }

  void searchBooks(String query) {
    _searchQuery.value = query;
    searchBooksByApi(query, category: _selectedGenre.value);
  }

  void filterByGenre(String genre) {
    _selectedGenre.value = genre;
    searchBooksByApi(_searchQuery.value, category: genre);
  }

  void filterByLanguage(String language) {
    _selectedLanguage.value = language;
  }

  Future<void> searchBooksByApi(String query, {String? category, bool refresh = true}) async {
    if (refresh) {
      _isLoading.value = true;
      _currentPage.value = 1;
      _hasMoreBooks.value = true;
    } else {
      if (_isLoadingMore.value || !_hasMoreBooks.value) return;
      _isLoadingMore.value = true;
    }

    try {
      final result = await _repository.searchBooks(
        query, 
        category: category,
        page: _currentPage.value,
        limit: 20
      );
      
      final newBooks = result['books'] as List<BookModel>;
      final total = result['total'] as int;

      if (refresh) {
        _books.value = newBooks;
      } else {
        _books.addAll(newBooks);
      }

      if (_books.length >= total || newBooks.isEmpty) {
        _hasMoreBooks.value = false;
      } else {
        _currentPage.value++;
      }
    } catch (e) {
      AppLogger.e('Error searching books by API', e);
    } finally {
      if (refresh) {
        _isLoading.value = false;
      } else {
        _isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreBooks() async {
    await searchBooksByApi(_searchQuery.value, category: _selectedGenre.value, refresh: false);
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

  Future<void> fetchBookDetails(String id) async {
    try {
      isLoadingDetails.value = true;
      currentBook.value = null; // Clear previous data
      
      final book = await _repository.getBookDetails(id);
      currentBook.value = book;
    } catch (e) {
      AppLogger.e('Error loading book details', e);
      showSnackSafe('Error', 'Failed to load book details');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> fetchMyLibrary() async {
    try {
      _isLoadingLibrary.value = true;
      final readerRepo = Get.find<ReaderRepository>();
      final libraryData = await readerRepo.getMyLibrary();
      
      // Some endpoints might return a nested structure like { "book": {...} } inside the list
      // We will parse it dynamically. Often the book data is at the root.
      _myLibraryBooks.value = libraryData.map((data) {
        // If it comes as { "book": { ... } } or just the book object
        final bookMap = data.containsKey('book') ? data['book'] as Map<String, dynamic> : data;
        return BookModel.fromJson(bookMap);
      }).toList();
      AppLogger.i('My Library loaded: ${_myLibraryBooks.length}');
    } catch (e) {
      AppLogger.e('Error loading my library', e);
      // Silent error or show snackbar
      // showSnackSafe('Error', 'Failed to load library');
    } finally {
      _isLoadingLibrary.value = false;
    }
  }
}
