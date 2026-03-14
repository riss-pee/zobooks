import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/reader_repository.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/storage_helper.dart';

class ReaderController extends GetxController {
  final ReaderRepository _readerRepository;

  ReaderController(this._readerRepository);

  final BookModel? book = Get.arguments as BookModel?;

  // ── Core state ───────────────────────────────────────────────
  final _isLoading = true.obs;
  final _isChapterLoading = false.obs;
  final _currentChapterIndex = 0.obs;
  final _chapters = <Map<String, dynamic>>[].obs;
  final _currentChapterContent = ''.obs;
  final _currentChapterTitle = ''.obs;
  final _isFullScreen = false.obs;

  // DRM
  String? _drmSessionId;
  String _deviceId = 'flutter-app';

  final Map<int, String> _chapterCache = {};

  // ── Reading settings ─────────────────────────────────────────
  final _fontSize = 16.0.obs;
  final _isDarkMode = false.obs;
  final _themeType = 'light'.obs;
  final _fontFamily = 'Georgia'.obs;
  final _textAlign = 'left'.obs;
  final _brightness = 1.0.obs;
  final _lineHeight = 1.5.obs;

  // ── Bookmarks & Highlights ───────────────────────────────────
  final _bookmarks = <Map<String, dynamic>>[].obs;
  final _highlights = <Map<String, dynamic>>[].obs;

  // ── Progress ─────────────────────────────────────────────────
  final _readingProgress = 0.0.obs;
  Timer? _syncDebounce;
  final ScrollController scrollController = ScrollController();

  // ── Getters ──────────────────────────────────────────────────
  bool get isLoading => _isLoading.value;
  bool get isChapterLoading => _isChapterLoading.value;
  int get currentChapterIndex => _currentChapterIndex.value;
  List<Map<String, dynamic>> get chapters => _chapters;
  int get totalChapters => _chapters.length;
  String get currentChapterContent => _currentChapterContent.value;
  String get currentChapterTitle => _currentChapterTitle.value;
  bool get isFullScreen => _isFullScreen.value;

  double get fontSize => _fontSize.value;
  bool get isDarkMode => _isDarkMode.value;
  String get themeType => _themeType.value;
  String get fontFamily => _fontFamily.value;
  String get textAlign => _textAlign.value;
  double get brightness => _brightness.value;
  double get lineHeight => _lineHeight.value;

  List<Map<String, dynamic>> get bookmarks => _bookmarks;
  List<Map<String, dynamic>> get highlights => _highlights;
  double get readingProgress => _readingProgress.value;

  int get currentPage => _currentChapterIndex.value;
  int get totalPages => _chapters.length;

  bool isCurrentChapterBookmarked() {
    if (_chapters.isEmpty) return false;
    final currentChapter = _chapters[_currentChapterIndex.value];
    return _bookmarks.any((b) => b['chapter_id'] == currentChapter['id']);
  }

  String getProgressText() {
    if (_chapters.isEmpty) return '0%';
    return '${_readingProgress.value.toStringAsFixed(1)}%';
  }

  @override
  void onInit() {
    super.onInit();
    if (book != null) {
      _loadSettings();
      _initializeReader();
    }
  }

  @override
  void onClose() {
    _syncDebounce?.cancel();
    _syncProgressNow();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initializeReader() async {
    try {
      _isLoading.value = true;

      try {
        final drmResult = await _readerRepository.createDrmSession(
          bookId: book!.id,
          deviceId: _deviceId,
        );
        _drmSessionId = drmResult['session_id'];
        AppLogger.i('DRM session created: $_drmSessionId');
      } catch (e) {
        AppLogger.e('DRM session failed (continuing without)', e);
      }

      final chapterList = await _readerRepository.listChapters(book!.id);
      _chapters.value = chapterList;

      if (_chapters.isEmpty) {
        _isLoading.value = false;
        return;
      }

      int startChapter = 0;

      try {
        final progress = await _readerRepository.getProgress(book!.id);
        final lastPosition = progress['last_position'] as Map<String, dynamic>?;

        if (lastPosition != null && lastPosition['chapter_index'] != null) {
          startChapter = lastPosition['chapter_index'];
          if (startChapter >= _chapters.length) startChapter = 0;
        }

        _readingProgress.value =
            (progress['progress_percent'] as num?)?.toDouble() ?? 0.0;
      } catch (e) {
        AppLogger.e('Could not load progress', e);
      }

      await _loadChapter(startChapter);

      _loadBookmarks();
      _loadHighlights();

      _isLoading.value = false;
    } catch (e) {
      AppLogger.e('Reader initialization failed', e);
      _isLoading.value = false;

      showSnackSafe(
        'Error',
        'Failed to load book: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;

    _currentChapterIndex.value = index;
    _currentChapterTitle.value =
        _chapters[index]['title'] ?? 'Chapter ${index + 1}';

    if (_chapterCache.containsKey(index)) {
      _currentChapterContent.value = _chapterCache[index]!;
      return;
    }

    _isChapterLoading.value = true;

    try {
      final chapterData = await _readerRepository.getChapterContent(
        bookId: book!.id,
        chapterIndex: _chapters[index]['index'],
        drmSessionId: _drmSessionId,
      );

      final content = _parseContent(chapterData['content'] ?? '');

      _chapterCache[index] = content;
      _currentChapterContent.value = content;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
      });
    } catch (e) {
      AppLogger.e('Error loading chapter', e);
      _currentChapterContent.value = 'Failed to load chapter.';
    } finally {
      _isChapterLoading.value = false;
    }
  }

  String _parseContent(String xhtml) {
    if (xhtml.isEmpty) return '';

    String text = xhtml;

    text = text.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
    text = text.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');

    return text.trim();
  }

  Future<void> goToChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;
    await _loadChapter(index);
    _updateProgress();
  }

  Future<void> nextChapter() async {
    if (_currentChapterIndex.value < _chapters.length - 1) {
      await goToChapter(_currentChapterIndex.value + 1);
    }
  }

  Future<void> previousChapter() async {
    if (_currentChapterIndex.value > 0) {
      await goToChapter(_currentChapterIndex.value - 1);
    }
  }

  void goToPage(int page) => goToChapter(page);
  void nextPage() => nextChapter();
  void previousPage() => previousChapter();

  void _updateProgress() {
    if (_chapters.isEmpty) return;

    _readingProgress.value =
        ((_currentChapterIndex.value + 1) / _chapters.length) * 100;

    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), _syncProgressNow);
  }

  Future<void> _syncProgressNow() async {
    if (book == null || _chapters.isEmpty) return;

    try {
      final currentChapter = _chapters[_currentChapterIndex.value];

      await _readerRepository.syncProgress(
        bookId: book!.id,
        chapterId: currentChapter['id'],
        progressPercent: _readingProgress.value,
        lastPosition: {
          'chapter_index': _currentChapterIndex.value,
          'chapter_id': currentChapter['id'],
        },
      );
    } catch (e) {
      AppLogger.e('Progress sync failed', e);
    }
  }

  Future<void> _loadBookmarks() async {
    if (book == null) return;

    try {
      final result = await _readerRepository.getBookmarks(book!.id);
      final list = result['bookmarks'];

      if (list is List) {
        _bookmarks.value = List<Map<String, dynamic>>.from(
            list.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) {
      AppLogger.e('Error loading bookmarks', e);
    }
  }

  Future<void> toggleBookmark() async {
    if (book == null || _chapters.isEmpty) return;

    final currentChapter = _chapters[_currentChapterIndex.value];

    final existing = _bookmarks.firstWhereOrNull(
      (b) => b['chapter_id'] == currentChapter['id'],
    );

    if (existing != null) {
      await deleteBookmark(existing['id'].toString());
      showSnackSafe('Bookmark Removed', 'Bookmark removed');
    } else {
      final result = await _readerRepository.createBookmark(
        bookId: book!.id,
        chapterId: currentChapter['id'],
        location: {
          'chapter_index': _currentChapterIndex.value,
        },
      );

      if (result['bookmark'] != null) {
        _bookmarks.add(Map<String, dynamic>.from(result['bookmark']));
      }

      showSnackSafe('Bookmarked', 'Chapter bookmarked');
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _readerRepository.deleteBookmark(bookmarkId);
      _bookmarks.removeWhere((b) => b['id'].toString() == bookmarkId);
    } catch (e) {
      AppLogger.e('Error deleting bookmark', e);
    }
  }

  Future<void> _loadHighlights() async {
    if (book == null) return;

    try {
      final result = await _readerRepository.getHighlights(book!.id);
      final list = result['highlights'];

      if (list is List) {
        _highlights.value = List<Map<String, dynamic>>.from(
            list.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) {
      AppLogger.e('Error loading highlights', e);
    }
  }

  void toggleFullScreen() => _isFullScreen.value = !_isFullScreen.value;

  void setFontSize(double size) {
    if (size >= 12 && size <= 32) {
      _fontSize.value = size;
      StorageHelper.saveDouble('reader_font_size', size);
    }
  }

  void setThemeType(String type) {
    _themeType.value = type;
    _isDarkMode.value = (type == 'dark');
    StorageHelper.saveString('reader_theme_type', type);
  }

  void setFontFamily(String family) {
    _fontFamily.value = family;
    StorageHelper.saveString('reader_font_family', family);
  }

  void setTextAlign(String align) {
    _textAlign.value = align;
    StorageHelper.saveString('reader_text_align', align);
  }

  void toggleDarkMode() {
    _isDarkMode.value = !_isDarkMode.value;
    _themeType.value = _isDarkMode.value ? 'dark' : 'light';
    StorageHelper.saveString('reader_theme_type', _themeType.value);
  }

  void setBrightness(double value) {
    if (value >= 0 && value <= 1) {
      _brightness.value = value;
      StorageHelper.saveDouble('reader_brightness', value);
    }
  }

  void setLineHeight(double value) {
    if (value >= 1 && value <= 2.5) {
      _lineHeight.value = value;
      StorageHelper.saveDouble('reader_line_height', value);
    }
  }

  void _loadSettings() {
    _fontSize.value = StorageHelper.getDouble('reader_font_size') ?? 16;
    _themeType.value = StorageHelper.getString('reader_theme_type') ?? 'light';
    _fontFamily.value =
        StorageHelper.getString('reader_font_family') ?? 'Georgia';
    _textAlign.value = StorageHelper.getString('reader_text_align') ?? 'left';
    _isDarkMode.value = _themeType.value == 'dark';
    _brightness.value = StorageHelper.getDouble('reader_brightness') ?? 1;
    _lineHeight.value = StorageHelper.getDouble('reader_line_height') ?? 1.5;
  }
}
