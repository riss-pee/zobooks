class PaymentModel {
  final String id;
  final String userId;
  final String bookId;
  final String type; // purchase, rental
  final double amount;
  final String status; // pending, completed, failed, refunded
  final String? paymentId; // Razorpay payment ID
  final String? orderId; // Razorpay order ID
  final DateTime? rentalExpiryDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentId,
    this.orderId,
    this.rentalExpiryDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bookId: json['book_id'] ?? '',
      type: json['type'] ?? 'purchase',
      amount: json['amount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentId: json['payment_id'],
      orderId: json['order_id'],
      rentalExpiryDate: json['rental_expiry_date'] != null
          ? DateTime.parse(json['rental_expiry_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'type': type,
      'amount': amount,
      'status': status,
      'payment_id': paymentId,
      'order_id': orderId,
      'rental_expiry_date': rentalExpiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

