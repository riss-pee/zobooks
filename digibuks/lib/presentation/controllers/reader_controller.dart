import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/book_model.dart';
// Removed unused imports: sample_content and app_constants were not used here
import '../../core/utils/logger.dart';
import '../../core/utils/storage_helper.dart';

class ReaderController extends GetxController {
  final BookModel? book = Get.arguments as BookModel?;
  
  // Reading state
  final _currentPage = 0.obs;
  final _totalPages = 0.obs;
  final _isLoading = true.obs;
  final _isFullScreen = false.obs;
  
  // Reading settings
  final _fontSize = 16.0.obs;
  final _isDarkMode = false.obs;
  final _brightness = 1.0.obs;
  final _lineHeight = 1.5.obs;
  
  // Bookmarks
  final _bookmarks = <int>[].obs;
  final _notes = <String, String>{}.obs; // page -> note
  
  // Reading progress
  final _readingProgress = 0.0.obs;
  final _lastReadPosition = 0.obs;

  // Getters
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  bool get isLoading => _isLoading.value;
  bool get isFullScreen => _isFullScreen.value;
  double get fontSize => _fontSize.value;
  bool get isDarkMode => _isDarkMode.value;
  double get brightness => _brightness.value;
  double get lineHeight => _lineHeight.value;
  List<int> get bookmarks => _bookmarks;
  Map<String, String> get notes => _notes;
  double get readingProgress => _readingProgress.value;
  int get lastReadPosition => _lastReadPosition.value;

  @override
  void onInit() {
    super.onInit();
    if (book != null) {
      _initializeReader();
      _loadReadingProgress();
      _loadBookmarks();
      _loadSettings();
    }
  }

  Future<void> _initializeReader() async {
    try {
      _isLoading.value = true;
      
      // Simulate loading book
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Set total pages based on book
      if (book!.pageCount != null) {
        _totalPages.value = book!.pageCount!;
      } else {
        // Default pages for demo
        _totalPages.value = 100;
      }
      
      // Load last read position
      _currentPage.value = _lastReadPosition.value;
      
      _isLoading.value = false;
      AppLogger.i('Reader initialized for book: ${book!.title}');
    } catch (e) {
      AppLogger.e('Error initializing reader', e);
      _isLoading.value = false;
    }
  }

  Future<void> _loadReadingProgress() async {
    try {
      final progressKey = 'reading_progress_${book!.id}';
      final progress = StorageHelper.getDouble(progressKey);
      if (progress != null) {
        _readingProgress.value = progress;
        _lastReadPosition.value = (progress * _totalPages.value).toInt();
      }
    } catch (e) {
      AppLogger.e('Error loading reading progress', e);
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarksKey = 'bookmarks_${book!.id}';
      final bookmarksJson = StorageHelper.getString(bookmarksKey);
      if (bookmarksJson != null) {
        // Parse bookmarks from JSON (simplified for demo)
        _bookmarks.value = [];
      }
    } catch (e) {
      AppLogger.e('Error loading bookmarks', e);
    }
  }

  Future<void> _loadSettings() async {
    try {
      _fontSize.value = StorageHelper.getDouble('reader_font_size') ?? 16.0;
      _isDarkMode.value = StorageHelper.getBool('reader_dark_mode') ?? false;
      _brightness.value = StorageHelper.getDouble('reader_brightness') ?? 1.0;
      _lineHeight.value = StorageHelper.getDouble('reader_line_height') ?? 1.5;
    } catch (e) {
      AppLogger.e('Error loading reader settings', e);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < _totalPages.value) {
      _currentPage.value = page;
      _updateReadingProgress();
    }
  }

  void nextPage() {
    if (_currentPage.value < _totalPages.value - 1) {
      _currentPage.value++;
      _updateReadingProgress();
    }
  }

  void previousPage() {
    if (_currentPage.value > 0) {
      _currentPage.value--;
      _updateReadingProgress();
    }
  }

  void toggleFullScreen() {
    _isFullScreen.value = !_isFullScreen.value;
  }

  void setFontSize(double size) {
    if (size >= 12 && size <= 24) {
      _fontSize.value = size;
      StorageHelper.saveDouble('reader_font_size', size);
    }
  }

  void toggleDarkMode() {
    _isDarkMode.value = !_isDarkMode.value;
    StorageHelper.saveBool('reader_dark_mode', _isDarkMode.value);
  }

  void setBrightness(double value) {
    if (value >= 0.0 && value <= 1.0) {
      _brightness.value = value;
      StorageHelper.saveDouble('reader_brightness', value);
    }
  }

  void setLineHeight(double value) {
    if (value >= 1.0 && value <= 2.5) {
      _lineHeight.value = value;
      StorageHelper.saveDouble('reader_line_height', value);
    }
  }

  void toggleBookmark() {
    if (_bookmarks.contains(_currentPage.value)) {
      _bookmarks.remove(_currentPage.value);
      showSnackSafe('Bookmark Removed', 'Bookmark removed from page ${_currentPage.value + 1}');
    } else {
      _bookmarks.add(_currentPage.value);
      showSnackSafe('Bookmarked', 'Page ${_currentPage.value + 1} bookmarked');
    }
    _saveBookmarks();
  }

  bool isBookmarked(int page) {
    return _bookmarks.contains(page);
  }

  void addNote(String note) {
    _notes[_currentPage.value.toString()] = note;
    showSnackSafe('Note Added', 'Note added to page ${_currentPage.value + 1}');
  }

  String? getNote(int page) {
    return _notes[page.toString()];
  }

  void _updateReadingProgress() {
    if (_totalPages.value > 0) {
      _readingProgress.value = _currentPage.value / _totalPages.value;
      _lastReadPosition.value = _currentPage.value;
      
      // Save progress
      final progressKey = 'reading_progress_${book!.id}';
      StorageHelper.saveDouble(progressKey, _readingProgress.value);
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      // Save bookmarks as JSON (simplified for demo)
      // In real app, serialize the list properly to a key like
      // 'bookmarks_${book!.id}' and persist via StorageHelper.
    } catch (e) {
      AppLogger.e('Error saving bookmarks', e);
    }
  }

  String getProgressText() {
    if (_totalPages.value == 0) return '0%';
    final percentage = (_readingProgress.value * 100).toInt();
    return '$percentage%';
  }
}

