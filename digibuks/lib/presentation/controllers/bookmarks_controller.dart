import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/chapter_bookmark_model.dart';
import '../../data/repositories/reader_repository.dart';
import '../../core/utils/logger.dart';

class BookmarksController extends GetxController {
  final _chapterBookmarks = <ChapterBookmarkModel>[].obs;
  final _isLoading = false.obs;

  final box = GetStorage();
  late final ReaderRepository _readerRepository;

  static const String _bookmarksKey = 'user_chapter_bookmarks';

  // Getters
  List<ChapterBookmarkModel> get chapterBookmarks => _chapterBookmarks;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Get reader repository from GetX
    try {
      _readerRepository = Get.find<ReaderRepository>();
    } catch (e) {
      AppLogger.w('ReaderRepository not found in GetX', e);
    }
    loadBookmarks();
  }

  /// Load bookmarks from API and cache them locally
  Future<void> loadBookmarks() async {
    try {
      _isLoading.value = true;

      // Try to fetch from API first
      try {
        final bookmarks = await _fetchAllUserBookmarks();
        _chapterBookmarks.value = bookmarks;

        // Cache locally
        await _saveBookmarksLocally(bookmarks);
        AppLogger.i('Chapter bookmarks loaded: ${_chapterBookmarks.length}');
      } catch (e) {
        AppLogger.w('Failed to fetch from API, loading from cache', e);
        // Fall back to cached bookmarks
        await _loadBookmarksFromCache();
      }
    } catch (e) {
      AppLogger.e('Error loading bookmarks', e);
      showSnackSafe('Error', 'Failed to load bookmarks');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch all bookmarks for the current user from API
  Future<List<ChapterBookmarkModel>> _fetchAllUserBookmarks() async {
    try {
      // Make API call to get all bookmarks
      final response = await _readerRepository.getAllUserBookmarks();

      final bookmarksList = response['bookmarks'] as List? ?? [];
      return bookmarksList
          .map((item) =>
              ChapterBookmarkModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.e('Error fetching bookmarks from API', e);
      rethrow;
    }
  }

  /// Load bookmarks from local cache
  Future<void> _loadBookmarksFromCache() async {
    try {
      final cachedList = box.read(_bookmarksKey) ?? [];
      if (cachedList is List) {
        _chapterBookmarks.value = cachedList
            .map((item) =>
                ChapterBookmarkModel.fromJson(item as Map<String, dynamic>))
            .toList();
        AppLogger.i(
            'Chapter bookmarks loaded from cache: ${_chapterBookmarks.length}');
      }
    } catch (e) {
      AppLogger.e('Error loading bookmarks from cache', e);
    }
  }

  /// Save bookmarks locally
  Future<void> _saveBookmarksLocally(
      List<ChapterBookmarkModel> bookmarks) async {
    try {
      final bookmarksList =
          bookmarks.map((bookmark) => bookmark.toJson()).toList();
      await box.write(_bookmarksKey, bookmarksList);
      AppLogger.i('Bookmarks cached: ${bookmarksList.length}');
    } catch (e) {
      AppLogger.e('Error saving bookmarks to cache', e);
    }
  }

  /// Remove a bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    try {
      await _readerRepository.deleteBookmark(bookmarkId);
      _chapterBookmarks.removeWhere((b) => b.id == bookmarkId);
      await _saveBookmarksLocally(_chapterBookmarks);

      showSnackSafe(
        'Removed',
        'Bookmark removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      AppLogger.i('Bookmark removed: $bookmarkId');
    } catch (e) {
      AppLogger.e('Error removing bookmark', e);
      showSnackSafe('Error', 'Failed to remove bookmark');
    }
  }

  /// Check if a chapter is bookmarked
  bool isChapterBookmarked(String bookId, String chapterId) {
    return _chapterBookmarks
        .any((b) => b.bookId == bookId && b.chapterId == chapterId);
  }

  /// Sync bookmarks - call this when reader bookmarks change
  Future<void> syncBookmarks() async {
    await loadBookmarks();
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      // Delete all bookmarks via API
      for (final bookmark in _chapterBookmarks) {
        try {
          await _readerRepository.deleteBookmark(bookmark.id);
        } catch (e) {
          AppLogger.e('Error deleting bookmark ${bookmark.id}', e);
        }
      }

      _chapterBookmarks.clear();
      await box.remove(_bookmarksKey);
      AppLogger.i('All bookmarks cleared');
    } catch (e) {
      AppLogger.e('Error clearing bookmarks', e);
      showSnackSafe('Error', 'Failed to clear bookmarks');
    }
  }
}
