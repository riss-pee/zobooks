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

  // Chapter content cache: chapterIndex -> content
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

  // Keep old getters for compatibility
  int get currentPage => _currentChapterIndex.value;
  int get totalPages => _chapters.length;

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
    // Sync progress one final time on close
    _syncProgressNow();
    scrollController.dispose();
    super.onClose();
  }

  // ── Initialization ───────────────────────────────────────────

  Future<void> _initializeReader() async {
    try {
      _isLoading.value = true;

      // 1. Create DRM session
      try {
        final drmResult = await _readerRepository.createDrmSession(
          bookId: book!.id,
          deviceId: _deviceId,
        );
        _drmSessionId = drmResult['session_id'];
        AppLogger.i('DRM session created: $_drmSessionId');
      } catch (e) {
        AppLogger.e('DRM session failed (continuing without)', e);
        // Continue without DRM — backend may allow it for some books
      }

      // 2. Fetch chapter list
      final chapterList = await _readerRepository.listChapters(book!.id);
      _chapters.value = chapterList;
      AppLogger.i('Loaded ${chapterList.length} chapters');

      if (_chapters.isEmpty) {
        _isLoading.value = false;
        return;
      }

      // 3. Load saved progress to resume
      int startChapter = 0;
      try {
        final progress = await _readerRepository.getProgress(book!.id);
        final lastPosition = progress['last_position'] as Map<String, dynamic>?;
        if (lastPosition != null && lastPosition['chapter_index'] != null) {
          startChapter = lastPosition['chapter_index'] as int;
          // Clamp to valid range
          if (startChapter >= _chapters.length) startChapter = 0;
        }
        _readingProgress.value = (progress['progress_percent'] as num?)?.toDouble() ?? 0.0;
      } catch (e) {
        AppLogger.e('Could not load progress (starting from beginning)', e);
      }

      // 4. Load first chapter content
      await _loadChapter(startChapter);

      // 5. Load bookmarks & highlights in parallel
      _loadBookmarks();
      _loadHighlights();

      _isLoading.value = false;
    } catch (e) {
      AppLogger.e('Reader initialization failed', e);
      _isLoading.value = false;
      showSnackSafe('Error', 'Failed to load book: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Chapter loading ──────────────────────────────────────────

  Future<void> _loadChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;

    _currentChapterIndex.value = index;
    _currentChapterTitle.value = _chapters[index]['title'] ?? 'Chapter ${index + 1}';

    // Check cache first
    if (_chapterCache.containsKey(index)) {
      _currentChapterContent.value = _chapterCache[index]!;
      _prefetchNextChapter(index);
      return;
    }

    _isChapterLoading.value = true;
    try {
      final chapterData = await _readerRepository.getChapterContent(
        bookId: book!.id,
        chapterIndex: _chapters[index]['index'] as int,
        drmSessionId: _drmSessionId,
      );

      final rawContent = _parseContent(chapterData['content'] as String? ?? '');
      // Strip duplicate chapter title from start of content
      final content = _removeDuplicateTitle(rawContent, _currentChapterTitle.value);
      _chapterCache[index] = content;
      _currentChapterContent.value = content;

      // Scroll to top
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(0.0);
        }
      });

      // Prefetch next chapter
      _prefetchNextChapter(index);
    } catch (e) {
      AppLogger.e('Error loading chapter $index', e);
      _currentChapterContent.value = 'Failed to load chapter. Please try again.';
    } finally {
      _isChapterLoading.value = false;
    }
  }

  /// Prefetch the next chapter silently
  void _prefetchNextChapter(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex < _chapters.length && !_chapterCache.containsKey(nextIndex)) {
      // Fire and forget
      _readerRepository
          .getChapterContent(
            bookId: book!.id,
            chapterIndex: _chapters[nextIndex]['index'] as int,
            drmSessionId: _drmSessionId,
          )
          .then((data) {
        final rawContent = _parseContent(data['content'] as String? ?? '');
        final nextTitle = _chapters[nextIndex]['title'] ?? '';
        _chapterCache[nextIndex] = _removeDuplicateTitle(rawContent, nextTitle);
        AppLogger.i('Prefetched chapter ${nextIndex + 1}');
      }).catchError((e) {
        AppLogger.e('Prefetch failed for chapter ${nextIndex + 1}', e);
      });
    }
  }

  /// Parse XHTML content to plain text with paragraph breaks
  String _parseContent(String xhtml) {
    if (xhtml.isEmpty) return '';

    String text = xhtml;
    // 1. Remove <style>...</style> blocks entirely (CSS rules showing as text)
    text = text.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '');
    // 2. Remove <script>...</script> blocks
    text = text.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), '');
    // 3. Remove <!-- comments -->
    text = text.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
    // 4. Replace common XHTML paragraph/break tags with newlines
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    text = text.replaceAll(RegExp(r'</p>'), '\n\n');
    text = text.replaceAll(RegExp(r'</div>'), '\n\n');
    text = text.replaceAll(RegExp(r'</h[1-6]>'), '\n\n');
    text = text.replaceAll(RegExp(r'</li>'), '\n');
    // 5. Strip all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // 6. Decode HTML entities
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&mdash;', '—');
    text = text.replaceAll('&ndash;', '–');
    text = text.replaceAll('&lsquo;', ''');
    text = text.replaceAll('&rsquo;', ''');
    text = text.replaceAll('&ldquo;', '\u201C');
    text = text.replaceAll('&rdquo;', '\u201D');
    text = text.replaceAll('&hellip;', '…');
    // 7. Clean up excessive whitespace
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.replaceAll(RegExp(r' {2,}'), ' ');
    text = text.trim();

    return text;
  }

  /// Remove duplicate chapter title from the start of parsed content
  String _removeDuplicateTitle(String content, String title) {
    if (title.isEmpty || content.isEmpty) return content;
    final trimmedTitle = title.trim();
    final trimmedContent = content.trimLeft();
    // Check if content starts with the title (case-insensitive)
    if (trimmedContent.toLowerCase().startsWith(trimmedTitle.toLowerCase())) {
      return trimmedContent.substring(trimmedTitle.length).trimLeft();
    }
    return content;
  }

  // ── Navigation ───────────────────────────────────────────────

  Future<void> goToChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;
    if (index == _currentChapterIndex.value) return;

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

  // Keep old methods for compatibility
  void goToPage(int page) => goToChapter(page);
  void nextPage() => nextChapter();
  void previousPage() => previousChapter();

  // ── Progress ─────────────────────────────────────────────────

  void _updateProgress() {
    if (_chapters.isEmpty) return;
    _readingProgress.value =
        ((_currentChapterIndex.value + 1) / _chapters.length) * 100;

    // Debounce sync: wait 2 seconds after last chapter change
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), _syncProgressNow);
  }

  Future<void> _syncProgressNow() async {
    if (book == null || _chapters.isEmpty) return;
    try {
      final currentChapter = _chapters[_currentChapterIndex.value];
      await _readerRepository.syncProgress(
        bookId: book!.id,
        chapterId: currentChapter['id'] as String?,
        progressPercent: _readingProgress.value,
        lastPosition: {
          'chapter_index': _currentChapterIndex.value,
          'chapter_id': currentChapter['id'],
        },
      );
      AppLogger.i('Progress synced: ${_readingProgress.value.toStringAsFixed(1)}%');
    } catch (e) {
      AppLogger.e('Progress sync failed', e);
    }
  }

  String getProgressText() {
    if (_chapters.isEmpty) return '0%';
    return '${_readingProgress.value.toStringAsFixed(0)}%';
  }

  // ── Bookmarks ────────────────────────────────────────────────

  Future<void> _loadBookmarks() async {
    if (book == null) return;
    try {
      final result = await _readerRepository.getBookmarks(book!.id);
      final list = result['bookmarks'];
      if (list is List) {
        _bookmarks.value = List<Map<String, dynamic>>.from(
          list.map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } catch (e) {
      AppLogger.e('Error loading bookmarks', e);
    }
  }

  Future<void> toggleBookmark() async {
    if (book == null || _chapters.isEmpty) return;

    final currentChapter = _chapters[_currentChapterIndex.value];

    // Check if already bookmarked
    final existing = _bookmarks.firstWhereOrNull(
      (b) => b['chapter_id']?.toString() == currentChapter['id']?.toString(),
    );

    if (existing != null) {
      // Delete bookmark
      try {
        await _readerRepository.deleteBookmark(existing['id'].toString());
        _bookmarks.removeWhere(
          (b) => b['id'].toString() == existing['id'].toString(),
        );
        showSnackSafe('Bookmark Removed', 'Bookmark removed',
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        AppLogger.e('Error deleting bookmark', e);
      }
    } else {
      // Create bookmark
      try {
        final result = await _readerRepository.createBookmark(
          bookId: book!.id,
          chapterId: currentChapter['id'] as String?,
          location: {
            'chapter_index': _currentChapterIndex.value,
            'chapter_title': currentChapter['title'],
          },
        );
        if (result['bookmark'] != null) {
          _bookmarks.add(Map<String, dynamic>.from(result['bookmark']));
        }
        showSnackSafe(
          'Bookmarked',
          '${currentChapter['title']} bookmarked',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        AppLogger.e('Error creating bookmark', e);
      }
    }
  }

  bool isCurrentChapterBookmarked() {
    if (_chapters.isEmpty) return false;
    final currentChapter = _chapters[_currentChapterIndex.value];
    return _bookmarks.any(
      (b) => b['chapter_id']?.toString() == currentChapter['id']?.toString(),
    );
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _readerRepository.deleteBookmark(bookmarkId);
      _bookmarks.removeWhere((b) => b['id'].toString() == bookmarkId);
      showSnackSafe('Bookmark Removed', 'Bookmark removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      AppLogger.e('Error deleting bookmark', e);
    }
  }

  // Keep old method for compatibility
  bool isBookmarked(int page) => isCurrentChapterBookmarked();

  // ── Highlights ───────────────────────────────────────────────

  Future<void> _loadHighlights() async {
    if (book == null) return;
    try {
      final result = await _readerRepository.getHighlights(book!.id);
      final list = result['highlights'];
      if (list is List) {
        _highlights.value = List<Map<String, dynamic>>.from(
          list.map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } catch (e) {
      AppLogger.e('Error loading highlights', e);
    }
  }

  Future<void> addHighlight(String text, {String color = 'yellow', String? note}) async {
    if (book == null || _chapters.isEmpty) return;
    final currentChapter = _chapters[_currentChapterIndex.value];
    try {
      final result = await _readerRepository.createHighlight(
        bookId: book!.id,
        chapterId: currentChapter['id'] as String?,
        text: text,
        color: color,
        location: {
          'chapter_index': _currentChapterIndex.value,
          'chapter_title': currentChapter['title'],
        },
        note: note,
      );
      if (result['highlight'] != null) {
        _highlights.add(Map<String, dynamic>.from(result['highlight']));
      }
      showSnackSafe('Highlighted', 'Text highlighted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      AppLogger.e('Error creating highlight', e);
    }
  }

  Future<void> deleteHighlight(String highlightId) async {
    try {
      await _readerRepository.deleteHighlight(highlightId);
      _highlights.removeWhere((h) => h['id'].toString() == highlightId);
    } catch (e) {
      AppLogger.e('Error deleting highlight', e);
    }
  }

  // ── Notes (compatibility shim) ──────────────────────────────
  void addNote(String note) {
    addHighlight('Note on ${currentChapterTitle}', note: note);
  }

  String? getNote(int page) => null;

  // ── UI Settings ──────────────────────────────────────────────

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

  void _loadSettings() {
    try {
      _fontSize.value = StorageHelper.getDouble('reader_font_size') ?? 16.0;
      _themeType.value = StorageHelper.getString('reader_theme_type') ?? 'light';
      _fontFamily.value = StorageHelper.getString('reader_font_family') ?? 'Georgia';
      _textAlign.value = StorageHelper.getString('reader_text_align') ?? 'left';
      _isDarkMode.value = (_themeType.value == 'dark');
      _brightness.value = StorageHelper.getDouble('reader_brightness') ?? 1.0;
      _lineHeight.value = StorageHelper.getDouble('reader_line_height') ?? 1.5;
    } catch (e) {
      AppLogger.e('Error loading reader settings', e);
    }
  }
}
