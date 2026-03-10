import '../../core/network/api_client.dart';
import '../models/grouped_books_model.dart';
import '../models/trending_book_model.dart';
import '../../core/exceptions/api_exception.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  Future<List<GroupedBooksModel>> getGroupedBooks() async {
    try {
      final response = await _apiClient.get('/reader/published-books/grouped');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => GroupedBooksModel.fromJson(json)).toList();
      } else {
        throw ApiException(message: 'Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<TrendingBookModel>> getTrendingBooks() async {
    try {
      final response = await _apiClient.get('/reader/trending-books');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => TrendingBookModel.fromJson(json)).toList();
      } else {
        throw ApiException(message: 'Failed to load trending books: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred getting trending: ${e.toString()}');
    }
  }
}

