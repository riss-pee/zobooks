class AppStrings {
  // English strings
  static const Map<String, String> EN = {
    // Auth Pages
    'welcome_back': 'Welcome Back',
    'username': 'Username',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'phone_number': 'Phone Number',
    'forgot_password_question': 'Forgot Password?',
    'login': 'Login',
    'dont_have_account': "Don't have an account?",
    'sign_up': 'Sign Up',
    'forgot_password': 'Forgot Password',
    'reset_your_password': 'Reset Your Password',
    'reset_password_desc':
        'Enter your username and we will send a verification code to your registered email address.',
    'send_reset_code': 'Send Reset Code',
    'create_account': 'Create Account',
    'already_have_account': 'Already have an account?',

    // Profile Page
    'edit_profile': 'Edit Profile',
    'my_books': 'My Books',
    'bookmarks': 'Bookmarks',
    'logout': 'Logout',
    'login_signup': 'Login / Sign Up',
    'welcome_to_zo_reads': 'Welcome to Zo Reads',
    'login_create_account_desc':
        'Login or create an account to view your profile, manage your books, and more.',

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
    'first_name': 'First Name',
    'last_name': 'Last Name',
    'bio': 'Bio',
    'date_of_birth': 'Date of Birth (YYYY-MM-DD)',
    'gender': 'Gender',

    // Theme
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'theme_system': 'System',

    // Logout
    'logout_confirm': 'Are you sure you want to logout?',
    'cancel': 'Cancel',
    'logout_button': 'Logout',
    'close': 'Close',
  };

  // Mizo strings
  static const Map<String, String> MI = {
    // Auth Pages
    'welcome_back': 'Kan Lo Lawm A Che',
    'username': 'Hming',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'phone_number': 'Phone number',
    'forgot_password_question': 'Password i theihnghilh em?',
    'login': 'Luhna',
    'dont_have_account': 'Account i la nei lo em?',
    'sign_up': 'In Ziah Luhna',
    'forgot_password': 'Password Theihnghilh',
    'reset_your_password': 'Password Siam Tharna',
    'reset_password_desc':
        'I username chhu lut la, i email address ziah luh tawhah verification code kan rawn thawn ang',
    'send_reset_code': 'Reset Code Thawnna',
    'create_account': 'Account Siamna',
    'already_have_account': 'Account i nei tawh em?',

    // Profile Page
    'edit_profile': 'Profile Siamthatna',
    'my_books': 'Ka Lehkhabu Te',
    'bookmarks': 'Chhinchhiahte',
    'logout': 'Chhuahna',
    'login_signup': 'Luhna / Inziahluhna',
    'welcome_to_zo_reads': 'Zo Reads-ah\nKan Lo Lawm A Che',
    'login_create_account_desc':
        'I profile en tur te, i lehkhabute enkawl tur te, leh thil dangte ti turin lut rawh emaw account siam rawh.',

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
    'my_library': 'Lehkhabu Leite',

    // Edit Profile Fields
    'first_name': 'Hming hmasa',
    'last_name': 'Hming Hnuhnung',
    'bio': 'I Chanchin',
    'date_of_birth': 'Pian ni',
    'gender': 'Gender',

    // Theme
    'theme_light': 'Eng',
    'theme_dark': 'Thim',
    'theme_system': 'System',

    // Logout
    'logout_confirm': 'I chhuak duh tak tak em?',
    'cancel': 'Duh lo',
    'logout_button': 'Duh e',
    'close': 'Khárna',
  };

  static String get(String key, String languageCode) {
    final translations = languageCode == 'mi' ? MI : EN;
    return translations[key] ?? EN[key] ?? key;
  }
}
