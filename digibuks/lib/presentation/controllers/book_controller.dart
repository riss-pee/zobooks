import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../core/utils/logger.dart';

class BookController extends GetxController {
  final HomeRepository _homeRepository;

  BookController(this._homeRepository);

  // Observable state
  final _books = <BookModel>[].obs;
  final _featuredBooks = <BookModel>[].obs;
  final _availableCategories = <String>[].obs;
  final _availableLanguages = <String>[].obs;
  final _searchQuery = ''.obs;
  final _selectedGenre = ''.obs;
  final _selectedLanguage = ''.obs;
  final _sortBy = 'Newest'.obs;
  final _isLoading = false.obs;
  final _wishlist = <String>[].obs; // Book IDs

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  List<String> get availableCategories => _availableCategories;
  List<String> get availableLanguages => _availableLanguages;
  String get searchQuery => _searchQuery.value;
  String get selectedGenre => _selectedGenre.value;
  String get selectedLanguage => _selectedLanguage.value;
  String get sortBy => _sortBy.value;
  bool get isLoading => _isLoading.value;
  List<String> get wishlist => _wishlist;

  List<BookModel> get filteredBooks {
    final normalizedSearch = _searchQuery.value.trim().toLowerCase();
    final normalizedLanguage = _normalizeLanguage(_selectedLanguage.value);

    final filtered = _books.where((book) {
      final matchesSearch = normalizedSearch.isEmpty ||
          book.title.toLowerCase().contains(normalizedSearch) ||
          (book.authorName?.toLowerCase().contains(normalizedSearch) ?? false);
      final matchesGenre = _selectedGenre.value.isEmpty ||
          _selectedGenre.value == 'All' ||
          book.genres.any(
              (g) => g.toLowerCase() == _selectedGenre.value.toLowerCase());
      final matchesLanguage = _selectedLanguage.value.isEmpty ||
          _selectedLanguage.value == 'All' ||
          _normalizeLanguage(book.language) == normalizedLanguage;
      return matchesSearch && matchesGenre && matchesLanguage;
    }).toList();

    filtered.sort(_compareBooks);
    return filtered;
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
      _books.value = await _homeRepository.getPublishedBooks(
        category: _selectedGenre.value.isEmpty ? null : _selectedGenre.value,
      );
      if (_availableCategories.isEmpty) {
        _availableCategories.value = _extractCategories(_books);
      }
      if (_availableLanguages.isEmpty) {
        _availableLanguages.value = _extractLanguages(_books);
      }
      _featuredBooks.value = _books.take(5).toList();
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
      _featuredBooks.value = _books.take(5).toList();
    } catch (e) {
      AppLogger.e('Error loading featured books', e);
    }
  }

  void searchBooks(String query) {
    _searchQuery.value = query;
  }

  Future<void> filterByGenre(String genre) async {
    _selectedGenre.value = genre;
    await loadBooks();
  }

  void filterByLanguage(String language) {
    _selectedLanguage.value = language;
  }

  void setSortBy(String sortBy) {
    _sortBy.value = sortBy;
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

  List<String> _extractCategories(List<BookModel> books) {
    final categories = books
        .expand((book) => book.genres)
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...categories];
  }

  List<String> _extractLanguages(List<BookModel> books) {
    final languages = books
        .map((book) => _normalizeLanguage(book.language))
        .where((language) => language.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...languages];
  }

  String _normalizeLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    switch (normalized) {
      case 'english':
        return 'en';
      case 'mizo':
        return 'mizo';
      default:
        return normalized;
    }
  }

  int _compareBooks(BookModel a, BookModel b) {
    switch (_sortBy.value) {
      case 'Oldest':
        return (a.createdAt ?? DateTime(1970))
            .compareTo(b.createdAt ?? DateTime(1970));
      case 'Price: Low to High':
        return (a.price ?? 0).compareTo(b.price ?? 0);
      case 'Price: High to Low':
        return (b.price ?? 0).compareTo(a.price ?? 0);
      case 'Newest':
      default:
        return (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970));
    }
  }
}
