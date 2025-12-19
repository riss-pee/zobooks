import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/models/book_model.dart';
import '../../core/utils/logger.dart';

class AdminController extends GetxController {
  final _users = <UserModel>[].obs;
  final _pendingBooks = <BookModel>[].obs;
  final _isLoading = false.obs;
  final _totalUsers = 0.obs;
  final _totalBooks = 0.obs;
  final _totalRevenue = 0.0.obs;

  List<UserModel> get users => _users;
  List<BookModel> get pendingBooks => _pendingBooks;
  bool get isLoading => _isLoading.value;
  int get totalUsers => _totalUsers.value;
  int get totalBooks => _totalBooks.value;
  double get totalRevenue => _totalRevenue.value;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadUsers();
    loadPendingBooks();
  }

  Future<void> loadStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _totalUsers.value = 1250;
      _totalBooks.value = 3500;
      _totalRevenue.value = 125000.0;
    } catch (e) {
      AppLogger.e('Error loading stats', e);
    }
  }

  Future<void> loadUsers() async {
    try {
      _isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock users
      _users.value = List.generate(10, (index) {
        final roles = ['reader', 'author', 'admin'];
        return UserModel(
          id: 'user_$index',
          email: 'user$index@example.com',
          name: 'User ${index + 1}',
          phone: '+91 987654321$index',
          role: roles[index % roles.length],
          createdAt: DateTime.now().subtract(Duration(days: index * 10)),
          updatedAt: DateTime.now().subtract(Duration(days: index * 5)),
        );
      });
    } catch (e) {
      AppLogger.e('Error loading users', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadPendingBooks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock pending books
      _pendingBooks.value = List.generate(5, (index) {
        return BookModel(
          id: 'pending_book_$index',
          title: 'Pending Book ${index + 1}',
          description: 'Book awaiting approval',
          authorId: 'author_$index',
          authorName: 'Author ${index + 1}',
          fileType: 'pdf',
          language: 'english',
          type: 'purchase',
          price: 299.0,
          isPublished: false,
          createdAt: DateTime.now().subtract(Duration(days: index * 2)),
          updatedAt: DateTime.now().subtract(Duration(days: index)),
        );
      });
    } catch (e) {
      AppLogger.e('Error loading pending books', e);
    }
  }

  Future<void> approveBook(String bookId) async {
    _pendingBooks.removeWhere((book) => book.id == bookId);
    Get.snackbar('Approved', 'Book approved successfully');
  }

  Future<void> rejectBook(String bookId) async {
    _pendingBooks.removeWhere((book) => book.id == bookId);
    Get.snackbar('Rejected', 'Book rejected');
  }

  Future<void> deleteUser(String userId) async {
    _users.removeWhere((user) => user.id == userId);
    Get.snackbar('Deleted', 'User deleted successfully');
  }
}

