class AppStrings {
  // English strings
  static const Map<String, String> EN = {
    // Profile Page
    'edit_profile': 'Edit Profile',
    'my_books': 'My Books',
    'bookmarks': 'Bookmarks',

    // Home Page
    'greeting_morning': 'Good Morning,',
    'greeting_afternoon': 'Good Afternoon,',
    'greeting_evening': 'Good Evening,',
    'explore_books': 'Explore Books',
    'trending_now': 'Trending Now',
    'history': 'History',
    'horror': 'Horror',
    'novel': 'Novel',

    // Library Page
    'my_library': 'My Library',

    // Edit Profile Fields
    'username': 'Username',
    'first_name': 'First Name',
    'last_name': 'Last Name',
    'phone_number': 'Phone Number',
    'bio': 'Bio',
    'date_of_birth': 'Date of Birth (YYYY-MM-DD)',
    'gender': 'Gender',
  };

  // Mizo strings
  static const Map<String, String> MI = {
    // Profile Page
    'edit_profile': 'Profile siamṭhatna',
    'my_books': 'Ka Lehkhabu Te',
    'bookmarks': 'Chhinchhiahte',

    // Home Page
    'greeting_morning': 'Chibai le,',
    'greeting_afternoon': 'Chibai,',
    'greeting_evening': 'Tlai Chibai,',
    'explore_books': 'Lehkhabu Enkualna',
    'trending_now': 'Lar Zual Te',
    'history': 'Thil Hlui',
    'horror': 'Hlauhawm Lam',
    'novel': 'Thawnthu Thui',

    // Library Page
    'my_library': 'Lehkhabu Lei te',

    // Edit Profile Fields
    'username': 'Username',
    'first_name': 'Hming hmasa',
    'last_name': 'Hming Hnuhnung',
    'phone_number': 'Phone number',
    'bio': 'I Chanchin',
    'date_of_birth': 'Pian ni',
    'gender': 'Gender',
  };

  static String get(String key, String languageCode) {
    final translations = languageCode == 'mi' ? MI : EN;
    return translations[key] ?? EN[key] ?? key;
  }
}
