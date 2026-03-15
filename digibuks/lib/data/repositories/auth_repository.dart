import 'dart:convert';
import '../datasources/remote/auth_remote_datasource.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _remoteDataSource.login(username, password);
      
      // Save tokens
      if (response['access_token'] != null) {
        await StorageHelper.saveAccessToken(response['access_token'] as String);
      }
      if (response['refresh_token'] != null) {
        await StorageHelper.saveRefreshToken(response['refresh_token'] as String);
      }
      
      // Save user data
      if (response['user'] != null) {
        final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
        await StorageHelper.saveString('user_data', jsonEncode(user.toJson()));
        return user;
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      AppLogger.e('Login repository error', e);
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
      return await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phone: phone,
        role: role,
      );
    } catch (e) {
      AppLogger.e('Register repository error', e);
      rethrow;
    }
  }

  Future<bool> verifyRegistrationOtp({
    required String email,
    required String otp,
    required String username,
    required String password,
  }) async {
    try {
      await _remoteDataSource.verifyRegistrationOtp(email: email, otp: otp);
      
      // Auto-login after successful verification
      try {
        await login(username, password);
        return true;
      } catch (e) {
        AppLogger.e('Auto-login after OTP failed', e);
        return true; // Still completed registration
      }
    } catch (e) {
      AppLogger.e('OTP verification repository error', e);
      rethrow;
    }
  }

  Future<void> resendRegistrationOtp(String email) async {
    try {
      await _remoteDataSource.resendRegistrationOtp(email);
    } catch (e) {
      AppLogger.e('Resend OTP repository error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String username) async {
    try {
      return await _remoteDataSource.forgotPassword(username);
    } catch (e) {
      AppLogger.e('Forgot password repository error', e);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String username,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        username: username,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      AppLogger.e('Reset password repository error', e);
      rethrow;
    }
  }

  /// Restore user from local storage (no API call)
  Future<UserModel?> restoreUser() async {
    try {
      final userData = StorageHelper.getString('user_data');
      if (userData != null && userData.isNotEmpty) {
        final json = jsonDecode(userData) as Map<String, dynamic>;
        return UserModel.fromJson(json);
      }
    } catch (e) {
      AppLogger.e('Error restoring user from storage', e);
    }
    return null;
  }

  Future<UserModel> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      AppLogger.e('Get current user repository error', e);
      rethrow;
    }
  }

  Future<UserProfileModel> getUserProfile() async {
    try {
      return await _remoteDataSource.getUserProfile();
    } catch (e) {
      AppLogger.e('Get user profile repository error', e);
      rethrow;
    }
  }

  Future<UserProfileModel> updateUserProfile(Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.updateUserProfile(data);
    } catch (e) {
      AppLogger.e('Update user profile repository error', e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      await StorageHelper.clearAll();
    } catch (e) {
      AppLogger.e('Logout repository error', e);
      // Clear storage even if API call fails
      await StorageHelper.clearAll();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageHelper.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getStoredToken() async {
    return await StorageHelper.getAccessToken();
  }
}

