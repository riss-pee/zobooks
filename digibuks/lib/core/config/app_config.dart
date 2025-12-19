class AppConfig {
  // App Information
  static const String appName = 'DigiBuks';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.digibuks.com'; // Update with actual backend URL
  static const String apiVersion = '/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Book Settings
  static const int maxRentalDays = 30;
  static const int minRentalDays = 1;
}

