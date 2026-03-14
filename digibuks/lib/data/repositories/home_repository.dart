import '../../core/network/api_client.dart';
import '../models/grouped_books_model.dart';
import '../models/trending_book_model.dart';
import '../models/book_model.dart';
import '../models/category_model.dart';
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

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('/books/categories');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw ApiException(message: 'Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error fetching categories: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> searchBooks(String query, {String? category, int page = 1, int limit = 20}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (query.isNotEmpty) queryParams['search'] = query;
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }

      final response = await _apiClient.get('/reader/published-books', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final booksData = data['books'] ?? [];
        final booksList = (booksData as List<dynamic>)
            .map((json) => BookModel.fromJson(json))
            .toList();
        return {
          'books': booksList,
          'total': data['total'] ?? 0,
        };
      } else {
        throw ApiException(message: 'Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error searching books: ${e.toString()}');
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

  Future<BookModel> getBookDetails(String id) async {
    try {
      final response = await _apiClient.get('/reader/published-books/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        return BookModel.fromJson(response.data);
      } else {
        throw ApiException(message: 'Failed to load book details: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred fetching book details: ${e.toString()}');
    }
  }
}

