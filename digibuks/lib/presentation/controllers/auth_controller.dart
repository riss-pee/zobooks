import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
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
  final _errorMessage = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  UserModel? get currentUser => _currentUser.value;
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
        await getCurrentUser();
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

      AppLogger.i('Login successful: ${user.email}'); // email holds username
      
      // Navigate to Home regardless of role for the Reader app
      Get.offAllNamed(AppConstants.homeRoute);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      AppLogger.e('Login failed: ${e.message}');
      showSnackSafe(
        'Login Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      AppLogger.e('Login error', e);
      showSnackSafe(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
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

      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phone: phone,
        role: role,
      );
      _currentUser.value = user;
      _isAuthenticated.value = true;

      AppLogger.i('Registration successful: ${user.email}');
      
      // Navigate to Home
      Get.offAllNamed(AppConstants.homeRoute);
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

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authRepository.logout();
      _currentUser.value = null;
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

