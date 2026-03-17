class AppStrings {
  // English strings
  static const Map<String, String> EN = {
    // Profile Page
    'edit_profile': 'Edit Profile',
    'my_books': 'My Books',
    'bookmarks': 'Bookmarks',
    'logout': 'Logout',
    'login_signup': 'Login / Sign Up',

    // Home Page
    'greeting_morning': 'Good Morning,',
    'greeting_afternoon': 'Good Afternoon,',
    'greeting_evening': 'Good Evening,',
    'explore_books': 'Explore Books',
    'trending_now': 'Trending Now',
    'latest_published': 'Latest Published',
    'see_all': 'See All',
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
    'edit_profile': 'Profile Siamṭhatna',
    'my_books': 'Ka Lehkhabu Te',
    'bookmarks': 'Chhinchhiahte',
    'logout': 'Chhuahna',
    'login_signup': 'Luhna / Inziahluhna',

    // Home Page
    'greeting_morning': 'Chibai le,',
    'greeting_afternoon': 'Chibai,',
    'greeting_evening': 'Tlai Chibai,',
    'explore_books': 'Lehkhabu Enkualna',
    'trending_now': 'Lar Zual Te',
    'latest_published': 'Tihchhuah thar berte',
    'see_all': 'En Vekna',
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
