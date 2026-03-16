import 'package:get/get.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/constants/app_strings.dart';

class LanguageController extends GetxController {
  final _language = 'en'.obs;

  Rx<String> get languageObservable => _language;
  String get language => _language.value;
  bool get isEnglish => _language.value == 'en';
  bool get isMizo => _language.value == 'mi';

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() {
    final storedLanguage = StorageHelper.getString('app_language') ?? 'en';
    _language.value = storedLanguage;
  }

  void setLanguage(String lang) {
    _language.value = lang;
    StorageHelper.saveString('app_language', lang);
    // You can add locale change logic here if needed
    // Get.updateLocale(Locale(lang));
  }

  String getLanguageName(String lang) {
    switch (lang) {
      case 'en':
        return 'English';
      case 'mi':
        return 'Mizo';
      default:
        return 'English';
    }
  }

  // Method to get translated strings
  String translate(String key) {
    return AppStrings.get(key, _language.value);
  }
}
