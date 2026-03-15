import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/api_exception.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  // Observable state
  final _isLoading = false.obs;
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<UserModel>();
  final _userProfile = Rxn<UserProfileModel>();
  final _errorMessage = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  UserModel? get currentUser => _currentUser.value;
  UserProfileModel? get userProfile => _userProfile.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.restoreUser();
        if (user != null) {
          _currentUser.value = user;
          _isAuthenticated.value = true;
          AppLogger.i('Session restored for: ${user.email}');
          // Fetch full profile in background
          fetchUserProfile();
        } else {
          // Token exists but no user data — clear invalid state
          _isAuthenticated.value = false;
        }
      }
    } catch (e) {
      AppLogger.e('Check auth status error', e);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final user = await _authRepository.login(username, password);
      _currentUser.value = user;
      _isAuthenticated.value = true;

      // Fetch full profile in background
      fetchUserProfile();

      AppLogger.i('Login successful: ${user.email}'); // email holds username
      
      // Navigate to Home regardless of role for the Reader app
      Get.offAllNamed(AppConstants.homeRoute);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      AppLogger.e('Login failed: ${e.message}');
      _showSecureLoginErrorModal();
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      AppLogger.e('Login error', e);
      _showSecureLoginErrorModal();
    } finally {
      _isLoading.value = false;
    }
  }

  void _showSecureLoginErrorModal() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Login Failed'),
          ],
        ),
        content: const Text(
          'Invalid username or password. Please try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    String role = AppConstants.roleReader,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phone: phone,
        role: role,
      );
      
      AppLogger.i('Registration step 1 successful: ${response['message']}');
      
      showSnackSafe(
        'OTP Sent',
        response['message'] ?? 'Please check your email for the verification code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to OTP verification screen
      Get.toNamed(
        AppConstants.registerOtpRoute,
        arguments: {
          'email': email,
          'username': username,
          'password': password,
        },
      );
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      AppLogger.e('Registration failed: ${e.message}');
      showSnackSafe(
        'Registration Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      AppLogger.e('Registration error', e);
      showSnackSafe(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> verifyRegistrationOtp({
    required String email,
    required String otp,
    required String username,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final success = await _authRepository.verifyRegistrationOtp(
        email: email,
        otp: otp,
        username: username,
        password: password,
      );

      if (success) {
        showSnackSafe(
          'Success',
          'Account verified successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // The repository auto-logs the user in, so we update the controller state
        await checkAuthStatus();
        
        // Navigate to Home
        Get.offAllNamed(AppConstants.homeRoute);
      }
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      AppLogger.e('OTP verification failed: ${e.message}');
      showSnackSafe(
        'Verification Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      AppLogger.e('OTP verification error', e);
      showSnackSafe(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resendRegistrationOtp(String email) async {
    try {
      _isLoading.value = true;
      
      await _authRepository.resendRegistrationOtp(email);
      
      showSnackSafe(
        'OTP Sent',
        'A new verification code has been sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      AppLogger.e('Resend OTP failed: ${e.message}');
      showSnackSafe(
        'Failed to Resend',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.e('Resend OTP error', e);
      showSnackSafe(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> requestPasswordReset(String username) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.forgotPassword(username);
      
      showSnackSafe(
        'Code Sent',
        response['message'] ?? 'If an account exists, a reset code has been sent.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to reset password screen
      Get.toNamed(
        AppConstants.resetPasswordRoute,
        arguments: {'username': username},
      );
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      showSnackSafe(
        'Request Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      showSnackSafe(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resetPassword({
    required String username,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _authRepository.resetPassword(
        username: username,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      showSnackSafe(
        'Success',
        'Password reset successfully. You can now login.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Go back to login screen
      Get.offAllNamed(AppConstants.loginRoute);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      showSnackSafe(
        'Reset Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      showSnackSafe(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser.value = user;
      _isAuthenticated.value = true;
    } catch (e) {
      AppLogger.e('Get current user error', e);
      _isAuthenticated.value = false;
      _currentUser.value = null;
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final profile = await _authRepository.getUserProfile();
      _userProfile.value = profile;
    } catch (e) {
      AppLogger.e('Fetch user profile error', e);
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final updatedProfile = await _authRepository.updateUserProfile(data);
      _userProfile.value = updatedProfile;
      AppLogger.i('User profile updated successfully');
    } catch (e) {
      AppLogger.e('Update user profile error', e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authRepository.logout();
      _currentUser.value = null;
      _userProfile.value = null;
      _isAuthenticated.value = false;
      
      Get.offAllNamed(AppConstants.homeRoute);
    } catch (e) {
      AppLogger.e('Logout error', e);
      // Clear local state even if API call fails
      _currentUser.value = null;
      _isAuthenticated.value = false;
      Get.offAllNamed(AppConstants.homeRoute);
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

  void _navigateAfterLogin(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        Get.offAllNamed(AppConstants.adminDashboardRoute);
        break;
      case AppConstants.roleAuthor:
        Get.offAllNamed(AppConstants.authorDashboardRoute);
        break;
      default:
        Get.offAllNamed(AppConstants.homeRoute);
    }
  }
}

