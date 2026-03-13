import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/snackbar_helper.dart';
import '../../controllers/payment_controller.dart';

import '../../../data/models/book_model.dart';
import '../../../core/theme/app_theme.dart';

class PaymentView extends StatelessWidget {
  final BookModel book;
  final String paymentType; // 'purchase' or 'rental'
  final int? rentalDays;

  const PaymentView({
    super.key,
    required this.book,
    required this.paymentType,
    this.rentalDays,
  });

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BOOK INFO
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.menu_book,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By ${book.authorName ?? "Unknown"}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(180),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// PAYMENT DETAILS
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPaymentRow(
                        context,
                        'Item',
                        paymentType == 'purchase' ? 'Purchase' : 'Rental',
                      ),
                      const Divider(),
                      if (paymentType == 'rental' && rentalDays != null)
                        _buildPaymentRow(
                          context,
                          'Rental Period',
                          '$rentalDays days',
                        ),
                      if (paymentType == 'rental' && rentalDays != null)
                        const Divider(),
                      _buildPaymentRow(
                        context,
                        'Amount',
                        '₹${_getPrice().toStringAsFixed(0)}',
                        isAmount: true,
                      ),
                      const Divider(),
                      _buildPaymentRow(
                        context,
                        'Total',
                        '₹${_getPrice().toStringAsFixed(0)}',
                        isAmount: true,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              /// PAY BUTTON
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: paymentController.isProcessing
                        ? null
                        : () => _processPayment(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: paymentController.isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary),
                            ),
                          )
                        : Text(
                            'Pay ₹${_getPrice().toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getPrice() {
    if (paymentType == 'purchase') {
      return book.price ?? 0;
    }
    return book.rentalPrice ?? 0;
  }

  Widget _buildPaymentRow(
    BuildContext context,
    String label,
    String value, {
    bool isAmount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isTotal
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isAmount || isTotal
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 18 : null,
                ),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    final controller = Get.find<PaymentController>();

    if (paymentType == 'purchase') {
      controller.purchaseBook(book);
    }

    /// Razorpay opens on top of this screen
    Navigator.of(context).pop();
  }
}
