import '../../core/network/api_client.dart';
import '../../core/exceptions/api_exception.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  /// POST /payments/create-order
  /// Returns: { order_id, amount, currency, key_id, book_title, book_id }
  Future<Map<String, dynamic>> createOrder(String bookId) async {
    try {
      final response = await _apiClient.post(
        '/payments/create-order',
        data: {'book_id': bookId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to create order: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error creating order: $e');
    }
  }

  /// POST /payments/verify
  /// Returns: { success, message, book_id, transaction_id }
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String bookId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/payments/verify',
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'book_id': bookId,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Payment verification failed: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error verifying payment: $e');
    }
  }

  /// GET /payments/check/{bookId}
  /// Returns: { owned, access_type?, purchased_at? }
  Future<Map<String, dynamic>> checkOwnership(String bookId) async {
    try {
      final response = await _apiClient.get('/payments/check/$bookId');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Ownership check failed: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error checking ownership: $e');
    }
  }

  /// POST /payments/claim-free/{bookId}
  /// Returns: { message, book_id }
  Future<Map<String, dynamic>> claimFreeBook(String bookId) async {
    try {
      final response = await _apiClient.post('/payments/claim-free/$bookId');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw ApiException(message: 'Failed to claim book: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Error claiming free book: $e');
    }
  }
}
