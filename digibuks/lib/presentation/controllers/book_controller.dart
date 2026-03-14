import 'package:get/get.dart';

import '../../core/utils/snackbar_helper.dart';
import '../../data/models/book_model.dart';
import '../../data/models/sample_books.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/home_repository.dart';

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
  final _wishlist = <String>[].obs;
  final _sortBy = 'Newest'.obs;

  final Rx<BookModel?> currentBook = Rx<BookModel?>(null);
  final RxBool isLoadingDetails = false.obs;

  // Added missing state variables
  final _categories = <String>[].obs;
  final _isCategoriesLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _isLoadingLibrary = false.obs;
  final _myLibraryBooks = <BookModel>[].obs;

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  String get searchQuery => _searchQuery.value;
  String get selectedGenre => _selectedGenre.value;
  String get selectedLanguage => _selectedLanguage.value;
  bool get isLoading => _isLoading.value;
  List<String> get wishlist => _wishlist;
  String get sortBy => _sortBy.value;

  // Added missing getters
  List<String> get categories => _categories;
  bool get isCategoriesLoading => _isCategoriesLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isLoadingLibrary => _isLoadingLibrary.value;
  List<BookModel> get myLibraryBooks => _myLibraryBooks;

  List<String> get availableCategories {
    final genres = <String>{'All'};
    for (var book in _books) {
      genres.addAll(book.genres);
    }
    return genres.toList()..sort();
  }

  List<String> get availableLanguages {
    final languages = <String>{'All'};
    for (var book in _books) {
      if (book.language.isNotEmpty) {
        languages.add(book.language);
      }
    }
    return languages.toList()..sort();
  }

  List<BookModel> get filteredBooks {
    return _books.where((book) {
      final matchesSearch =
          book.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
              (book.authorName
                      ?.toLowerCase()
                      .contains(_searchQuery.value.toLowerCase()) ??
                  false);

      final matchesGenre = _selectedGenre.value.isEmpty ||
          _selectedGenre.value == 'All' ||
          book.genres.any(
            (g) => g.toLowerCase() == _selectedGenre.value.toLowerCase(),
          );

      final matchesLanguage = _selectedLanguage.value.isEmpty ||
          _selectedLanguage.value == 'All' ||
          book.language.toLowerCase() == _selectedLanguage.value.toLowerCase();

      return matchesSearch && matchesGenre && matchesLanguage;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy.value) {
          case 'Oldest':
            return (a.publishedAt ?? DateTime(0))
                .compareTo(b.publishedAt ?? DateTime(0));
          case 'Price: Low to High':
            return (a.price ?? 0).compareTo(b.price ?? 0);
          case 'Price: High to Low':
            return (b.price ?? 0).compareTo(a.price ?? 0);
          case 'Newest':
          default:
            return (b.publishedAt ?? DateTime(0))
                .compareTo(a.publishedAt ?? DateTime(0));
        }
      });
  }

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

      await Future.delayed(const Duration(seconds: 1));

      _books.value = SampleBooks.getBooks();

      AppLogger.i('Books loaded: ${_books.length}');
    } catch (e) {
      AppLogger.e('Error loading books', e);

      showSnackSafe('Error', 'Failed to load books');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      _isCategoriesLoading.value = true;
      final cats = await _repository.getCategories();
      _categories.value = cats;
    } catch (e) {
      AppLogger.e('Error loading categories', e);
      _categories.value = ['Fiction', 'Non-Fiction', 'Science', 'History']; // Fallback
    } finally {
      _isCategoriesLoading.value = false;
    }
  }

  Future<void> searchBooksByApi(String query) async {
    _searchQuery.value = query;
    _isLoading.value = true;
    try {
      final result = await _repository.searchBooks(query);
      if (result['books'] != null) {
        _books.value = List<BookModel>.from(result['books']);
      }
    } catch (e) {
      AppLogger.e('Error searching API', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreBooks() async {
    if (_isLoadingMore.value) return;
    _isLoadingMore.value = true;
    // Simulate loading more
    await Future.delayed(const Duration(seconds: 1));
    _isLoadingMore.value = false;
  }

  Future<void> fetchMyLibrary() async {
    try {
      _isLoadingLibrary.value = true;
      // Simulate fetching
      await Future.delayed(const Duration(seconds: 1));
      _myLibraryBooks.value = _books.take(3).toList();
    } catch (e) {
      AppLogger.e('Error fetching library', e);
    } finally {
      _isLoadingLibrary.value = false;
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
  }

  void filterByGenre(String genre) {
    _selectedGenre.value = genre;
  }

  void filterByLanguage(String language) {
    _selectedLanguage.value = language;
  }

  void setSortBy(String sort) {
    _sortBy.value = sort;
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
    _wishlist.value = [];
  }

  Future<void> fetchBookDetails(String id) async {
    try {
      isLoadingDetails.value = true;
      currentBook.value = null;

      final book = await _repository.getBookDetails(id);

      currentBook.value = book;
    } catch (e) {
      AppLogger.e('Error loading book details', e);

      showSnackSafe(
        'Error',
        'Failed to load book details',
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }
}
