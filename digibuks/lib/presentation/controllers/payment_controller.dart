import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class PaymentController extends GetxController {
  final PaymentRepository _paymentRepository;

  PaymentController(this._paymentRepository);

  // Observable state
  final _isProcessing = false.obs;
  final _ownedBooks = <String, String>{}.obs; // bookId -> access_type

  // Getters
  bool get isProcessing => _isProcessing.value;

  // Track current purchase context
  String? _currentBookId;
  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  /// Check if the current user owns a specific book.
  /// Call this on BookDetail page load.
  Future<void> checkOwnership(String bookId) async {
    try {
      final result = await _paymentRepository.checkOwnership(bookId);
      if (result['owned'] == true) {
        _ownedBooks[bookId] = result['access_type'] ?? 'purchase';
      }
    } catch (e) {
      // Silently fail — user might not be authenticated
      AppLogger.e('Ownership check failed', e);
    }
  }

  /// Whether the user can access (owns/rented) a book.
  bool canAccessBook(String bookId) {
    return _ownedBooks.containsKey(bookId);
  }

  /// Initiate a Razorpay purchase for a paid book.
  Future<void> purchaseBook(BookModel book) async {
    try {
      _isProcessing.value = true;
      _currentBookId = book.id;

      // 1. Create order on backend
      final orderData = await _paymentRepository.createOrder(book.id);

      // 2. Open Razorpay checkout
      final options = {
        'key': orderData['key_id'],
        'amount': orderData['amount'], // already in paise from backend
        'currency': orderData['currency'],
        'order_id': orderData['order_id'],
        'name': 'DigiBuks',
        'description': 'Purchase: ${orderData['book_title'] ?? book.title}',
        'prefill': {
          'contact': '',
          'email': '',
        },
        'theme': {
          'color': '#2E4032', // matches our primary color
        },
      };

      _razorpay.open(options);
      // Razorpay callbacks will handle the rest
    } catch (e) {
      _isProcessing.value = false;
      AppLogger.e('Error starting purchase', e);
      showSnackSafe(
        'Error',
        e.toString().replaceAll('ApiException:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  /// Claim a free book.
  Future<void> claimFreeBook(BookModel book) async {
    try {
      _isProcessing.value = true;
      final result = await _paymentRepository.claimFreeBook(book.id);

      _ownedBooks[book.id] = 'free';

      showSnackSafe(
        'Success',
        'Book added to your library!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to reader
      Get.toNamed(AppConstants.readerRoute, arguments: book);
    } catch (e) {
      AppLogger.e('Error claiming free book', e);
      showSnackSafe(
        'Error',
        e.toString().replaceAll('ApiException:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  // ── Razorpay Callbacks ──────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.i('Payment success: ${response.paymentId}');

    try {
      // Verify on backend
      final result = await _paymentRepository.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        bookId: _currentBookId ?? '',
      );

      if (result['success'] == true) {
        _ownedBooks[_currentBookId ?? ''] = 'purchase';

        showSnackSafe(
          'Purchase Complete!',
          result['message'] ?? 'Book added to your library',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      AppLogger.e('Payment verification failed', e);
      showSnackSafe(
        'Verification Failed',
        'Payment was received but verification failed. Please contact support.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing.value = false;
    AppLogger.e('Payment failed: ${response.message}');
    showSnackSafe(
      'Payment Failed',
      response.message ?? 'Something went wrong. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.i('External wallet selected: ${response.walletName}');
    showSnackSafe(
      'External Wallet',
      'You selected: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
