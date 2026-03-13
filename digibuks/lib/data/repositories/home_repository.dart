import '../../core/network/api_client.dart';
import '../models/book_model.dart';
import '../models/grouped_books_model.dart';
import '../models/trending_book_model.dart';
import '../../core/exceptions/api_exception.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  Future<List<BookModel>> getPublishedBooks({String? category}) async {
    try {
      final trimmedCategory = category?.trim();
      final response = await _apiClient.get(
        '/reader/published-books',
        queryParameters: trimmedCategory != null && trimmedCategory.isNotEmpty
            ? {'category': trimmedCategory}
            : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) =>
                BookModel.fromPublishedBookJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          message: 'Failed to load published books: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message:
            'An unexpected error occurred loading published books: ${e.toString()}',
      );
    }
  }

  Future<List<GroupedBooksModel>> getGroupedBooks() async {
    try {
      final response = await _apiClient.get('/reader/published-books/grouped');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => GroupedBooksModel.fromJson(json)).toList();
      } else {
        throw ApiException(
            message: 'Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<TrendingBookModel>> getTrendingBooks() async {
    try {
      final response = await _apiClient.get('/reader/trending-books');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => TrendingBookModel.fromJson(json)).toList();
      } else {
        throw ApiException(
            message: 'Failed to load trending books: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
          message:
              'An unexpected error occurred getting trending: ${e.toString()}');
    }
  }
}
