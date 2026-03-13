import '../../../core/network/api_client.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final bool _useMockData;

  AuthRemoteDataSource(this._apiClient, {bool useMockData = false})
      : _useMockData = useMockData;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      AppLogger.i('Attempting login for: $username');

      final response = await _apiClient.post(
        '/users/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.i('Login successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.e('Login error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    String role = 'reader',
  }) async {
    try {
      AppLogger.i('Attempting registration for: $username');

      await _apiClient.post(
        '/users/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'role': role,
        },
      );

      // Registration endpoint does not return tokens → auto login
      AppLogger.i('Registration successful, auto-logging in...');

      final loginResponse = await _apiClient.post(
        '/users/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      return loginResponse.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('Registration error', e);
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      AppLogger.i('Fetching current user');

      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));

        return UserModel(
          id: 'demo_user_123',
          email: 'demo@digibuks.com',
          name: 'Demo User',
          phone: '+91 9876543210',
          role: AppConstants.roleReader,
          profileImage: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final response = await _apiClient.get('/users/auth/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(
          response.data['user'] as Map<String, dynamic>,
        );
      } else {
        throw ApiException(
          message: 'Failed to fetch user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.e('Get current user error', e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.i('Logging out');

      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 300));
        return;
      }

      await _apiClient.post('/users/auth/logout');
    } catch (e) {
      AppLogger.e('Logout error', e);
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      AppLogger.i('Refreshing token');

      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return {
          'access_token':
              'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token':
              'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        };
      }

      final response = await _apiClient.post(
        '/users/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.e('Token refresh error', e);
      rethrow;
    }
  }
}
