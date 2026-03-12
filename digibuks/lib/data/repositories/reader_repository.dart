import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/exceptions/api_exception.dart';

class ReaderRepository {
  final ApiClient _apiClient;

  ReaderRepository(this._apiClient);

  // ── DRM Session ──────────────────────────────────────────────

  /// POST /reader/drm/session
  Future<Map<String, dynamic>> createDrmSession({
    required String bookId,
    required String deviceId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/reader/drm/session',
        data: {'book_id': bookId},
        options: Options(headers: {'X-Device-ID': deviceId}),
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to create DRM session');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'DRM session error: $e');
    }
  }

  // ── Chapters ─────────────────────────────────────────────────

  /// GET /reader/reader/books/{bookId}/chapters
  Future<List<Map<String, dynamic>>> listChapters(String bookId) async {
    try {
      final response = await _apiClient.get('/reader/reader/books/$bookId/chapters');
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(
          (response.data as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      throw ApiException(message: 'Failed to load chapters');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error loading chapters: $e');
    }
  }

  /// GET /reader/books/{bookId}/chapters/{chapterIndex}
  Future<Map<String, dynamic>> getChapterContent({
    required String bookId,
    required int chapterIndex,
    String? drmSessionId,
  }) async {
    try {
      final headers = <String, dynamic>{};
      if (drmSessionId != null) {
        headers['X-DRM-Session'] = drmSessionId;
      }
      final response = await _apiClient.get(
        '/reader/books/$bookId/chapters/$chapterIndex',
        options: Options(headers: headers),
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to load chapter content');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error loading chapter: $e');
    }
  }

  // ── Reading Progress ────────────────────────────────────────

  /// POST /reader/progress/sync
  Future<Map<String, dynamic>> syncProgress({
    required String bookId,
    String? chapterId,
    required double progressPercent,
    required Map<String, dynamic> lastPosition,
  }) async {
    try {
      final progressEntry = {
        'book': {'id': bookId},
        'progress_percent': progressPercent,
        'last_position': lastPosition,
      };
      if (chapterId != null) {
        progressEntry['chapter'] = {'id': chapterId};
      }

      final response = await _apiClient.post(
        '/reader/progress/sync',
        data: {
          'progress_data': [progressEntry],
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to sync progress');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Progress sync error: $e');
    }
  }

  /// GET /reader/progress/{bookId}
  Future<Map<String, dynamic>> getProgress(String bookId) async {
    try {
      final response = await _apiClient.get('/reader/progress/$bookId');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to load progress');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error loading progress: $e');
    }
  }

  // ── Bookmarks ───────────────────────────────────────────────

  /// GET /reader/bookmarks?book_id=
  Future<Map<String, dynamic>> getBookmarks(String bookId) async {
    try {
      final response = await _apiClient.get(
        '/reader/bookmarks',
        queryParameters: {'book_id': bookId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to load bookmarks');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error loading bookmarks: $e');
    }
  }

  /// POST /reader/bookmarks
  Future<Map<String, dynamic>> createBookmark({
    required String bookId,
    String? chapterId,
    required Map<String, dynamic> location,
  }) async {
    try {
      final data = <String, dynamic>{
        'book_id': bookId,
        'location': location,
      };
      if (chapterId != null) {
        data['chapter_id'] = chapterId;
      }
      final response = await _apiClient.post('/reader/bookmarks', data: data);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to create bookmark');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error creating bookmark: $e');
    }
  }

  /// DELETE /reader/bookmarks/{id}
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _apiClient.delete('/reader/bookmarks/$bookmarkId');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error deleting bookmark: $e');
    }
  }

  // ── Highlights ──────────────────────────────────────────────

  /// GET /reader/highlights?book_id=
  Future<Map<String, dynamic>> getHighlights(String bookId) async {
    try {
      final response = await _apiClient.get(
        '/reader/highlights',
        queryParameters: {'book_id': bookId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to load highlights');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error loading highlights: $e');
    }
  }

  /// POST /reader/highlights
  Future<Map<String, dynamic>> createHighlight({
    required String bookId,
    String? chapterId,
    required String text,
    String color = 'yellow',
    required Map<String, dynamic> location,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'book_id': bookId,
        'text': text,
        'color': color,
        'location': location,
      };
      if (chapterId != null) data['chapter_id'] = chapterId;
      if (note != null) data['note'] = note;

      final response = await _apiClient.post('/reader/highlights', data: data);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to create highlight');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error creating highlight: $e');
    }
  }

  /// DELETE /reader/highlights/{id}
  Future<void> deleteHighlight(String highlightId) async {
    try {
      await _apiClient.delete('/reader/highlights/$highlightId');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error deleting highlight: $e');
    }
  }
}
