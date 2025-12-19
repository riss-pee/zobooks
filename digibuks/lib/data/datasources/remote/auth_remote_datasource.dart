import '../../../core/network/api_client.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final bool _useMockData;

  AuthRemoteDataSource(this._apiClient, {bool useMockData = true})
      : _useMockData = useMockData;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      AppLogger.i('Attempting login for: $email');
      
      // Mock authentication for demo
      if (_useMockData) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        
        // Demo credentials - accept any email/password or use specific ones
        final isDemoLogin = email.isNotEmpty && password.isNotEmpty;
        
        if (!isDemoLogin) {
          throw ApiException(
            message: 'Email and password are required',
            statusCode: 400,
          );
        }
        
        // Determine role based on email (for demo)
        String role = AppConstants.roleReader;
        if (email.contains('admin')) {
          role = AppConstants.roleAdmin;
        } else if (email.contains('author')) {
          role = AppConstants.roleAuthor;
        }
        
        final mockUser = UserModel(
          id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: email.split('@')[0].replaceAll('.', ' ').split(' ').map((word) => 
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
          ).join(' '),
          phone: '+91 9876543210',
          role: role,
          profileImage: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        return {
          'access_token': 'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token': 'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': mockUser.toJson(),
        };
      }
      
      // Real API call (when backend is ready)
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
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
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'reader',
  }) async {
    try {
      AppLogger.i('Attempting registration for: $email');
      
      // Mock registration for demo
      if (_useMockData) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        
        // Check if email already exists (mock check)
        if (email.isEmpty || password.isEmpty || name.isEmpty) {
          throw ApiException(
            message: 'All required fields must be filled',
            statusCode: 400,
          );
        }
        
        final mockUser = UserModel(
          id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          phone: phone,
          role: role,
          profileImage: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        return {
          'access_token': 'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token': 'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': mockUser.toJson(),
        };
      }
      
      // Real API call (when backend is ready)
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('Registration successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.e('Registration error', e);
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      AppLogger.i('Fetching current user');
      
      // Mock get current user for demo
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Return a demo user (in real app, this would come from storage or API)
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
      
      // Real API call
      final response = await _apiClient.get('/auth/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
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
      
      await _apiClient.post('/auth/logout');
    } catch (e) {
      AppLogger.e('Logout error', e);
      // Even if API call fails, we should clear local storage
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      AppLogger.i('Refreshing token');
      
      if (_useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return {
          'access_token': 'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token': 'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        };
      }
      
      final response = await _apiClient.post(
        '/auth/refresh',
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
