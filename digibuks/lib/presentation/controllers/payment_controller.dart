import 'package:get/get.dart';
import '../../data/models/book_model.dart';
import '../../data/models/payment_model.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/storage_helper.dart';

class PaymentController extends GetxController {
  // Observable state
  final _isProcessing = false.obs;
  final _paymentHistory = <PaymentModel>[].obs;
  final _purchasedBooks = <String>[].obs; // Book IDs
  final _rentedBooks = <String, DateTime>{}.obs; // Book ID -> Expiry Date

  // Getters
  bool get isProcessing => _isProcessing.value;
  List<PaymentModel> get paymentHistory => _paymentHistory;
  List<String> get purchasedBooks => _purchasedBooks;
  Map<String, DateTime> get rentedBooks => _rentedBooks;

  @override
  void onInit() {
    super.onInit();
    loadPaymentHistory();
    loadPurchasedBooks();
    loadRentedBooks();
  }

  Future<void> loadPaymentHistory() async {
    try {
      // Load from storage in real app
      _paymentHistory.value = [];
    } catch (e) {
      AppLogger.e('Error loading payment history', e);
    }
  }

  Future<void> loadPurchasedBooks() async {
    try {
      final purchasedKey = 'purchased_books';
      final purchasedJson = StorageHelper.getString(purchasedKey);
      if (purchasedJson != null) {
        // Parse JSON in real app
        _purchasedBooks.value = [];
      }
    } catch (e) {
      AppLogger.e('Error loading purchased books', e);
    }
  }

  Future<void> loadRentedBooks() async {
    try {
      final rentedKey = 'rented_books';
      final rentedJson = StorageHelper.getString(rentedKey);
      if (rentedJson != null) {
        // Parse JSON in real app
        _rentedBooks.value = {};
      }
    } catch (e) {
      AppLogger.e('Error loading rented books', e);
    }
  }

  Future<bool> purchaseBook(BookModel book) async {
    try {
      _isProcessing.value = true;
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful payment
      final payment = PaymentModel(
        id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        bookId: book.id,
        type: 'purchase',
        amount: book.price ?? 0.0,
        status: 'completed',
        paymentId: 'rzp_${DateTime.now().millisecondsSinceEpoch}',
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _paymentHistory.add(payment);
      _purchasedBooks.add(book.id);
      
      // Save to storage
      await _savePurchasedBooks();
      await _savePaymentHistory();
      
      AppLogger.i('Book purchased: ${book.title}');
      return true;
    } catch (e) {
      AppLogger.e('Error purchasing book', e);
      return false;
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<bool> rentBook(BookModel book, int days) async {
    try {
      _isProcessing.value = true;
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      final expiryDate = DateTime.now().add(Duration(days: days));
      
      // Mock successful payment
      final payment = PaymentModel(
        id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        bookId: book.id,
        type: 'rental',
        amount: book.rentalPrice ?? 0.0,
        status: 'completed',
        paymentId: 'rzp_${DateTime.now().millisecondsSinceEpoch}',
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        rentalExpiryDate: expiryDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _paymentHistory.add(payment);
      _rentedBooks[book.id] = expiryDate;
      
      // Save to storage
      await _saveRentedBooks();
      await _savePaymentHistory();
      
      AppLogger.i('Book rented: ${book.title} until $expiryDate');
      return true;
    } catch (e) {
      AppLogger.e('Error renting book', e);
      return false;
    } finally {
      _isProcessing.value = false;
    }
  }

  bool hasPurchased(String bookId) {
    return _purchasedBooks.contains(bookId);
  }

  bool hasRented(String bookId) {
    if (!_rentedBooks.containsKey(bookId)) return false;
    final expiryDate = _rentedBooks[bookId]!;
    return DateTime.now().isBefore(expiryDate);
  }

  bool canAccessBook(String bookId) {
    return hasPurchased(bookId) || hasRented(bookId);
  }

  DateTime? getRentalExpiry(String bookId) {
    return _rentedBooks[bookId];
  }

  Future<void> _savePurchasedBooks() async {
    // Save to storage in real app
  }

  Future<void> _saveRentedBooks() async {
    // Save to storage in real app
  }

  Future<void> _savePaymentHistory() async {
    // Save to storage in real app
  }
}

