class AppStrings {
  // English strings
  static const Map<String, String> EN = {
    // Profile Page
    'edit_profile': 'Edit Profile',
    'my_books': 'My Books',

    // Home Page
    'trending_now': 'Trending Now',
    'history': 'History',
    'horror': 'Horror',
    'novel': 'Novel',

    // Library Page
    'my_library': 'My Library',
  };

  // Mizo strings
  static const Map<String, String> MI = {
    // Profile Page
    'edit_profile': 'Profile Siamna',
    'my_books': 'Ka Lehkhabu Te',

    // Home Page
    'trending_now': 'Lar Zual Te',
    'history': 'Thil Hlui',
    'horror': 'Hlauhawm Lam',
    'novel': 'Thawnthu Thui',

    // Library Page
    'my_library': 'Lehkhabu Dahkhawm',
  };

  static String get(String key, String languageCode) {
    final translations = languageCode == 'mi' ? MI : EN;
    return translations[key] ?? EN[key] ?? key;
  }
}
