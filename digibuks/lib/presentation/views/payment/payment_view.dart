import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/snackbar_helper.dart';
import '../../controllers/payment_controller.dart';
import '../../../data/models/book_model.dart';
import '../../../core/theme/app_theme.dart';

class PaymentView extends StatelessWidget {
  final BookModel book;
  final String paymentType; // purchase / rental
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

    final amount =
        paymentType == 'purchase' ? (book.price ?? 0) : (book.rentalPrice ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "By ${book.authorName ?? "Unknown"}",
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
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// PAYMENT DETAILS
              Text(
                "Payment Details",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPaymentRow(
                        context,
                        "Item",
                        paymentType == "purchase" ? "Purchase" : "Rental",
                      ),
                      const Divider(),
                      if (paymentType == "rental" && rentalDays != null) ...[
                        _buildPaymentRow(
                          context,
                          "Rental Period",
                          "$rentalDays days",
                        ),
                        const Divider(),
                      ],
                      _buildPaymentRow(
                        context,
                        "Amount",
                        "₹${amount.toStringAsFixed(0)}",
                        isAmount: true,
                      ),
                      const Divider(),
                      _buildPaymentRow(
                        context,
                        "Total",
                        "₹${amount.toStringAsFixed(0)}",
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
                        : () {
                            _processPayment(context, paymentController);
                          },
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
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            "Pay ₹${amount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
          )
        ],
      ),
    );
  }

  void _processPayment(
    BuildContext context,
    PaymentController controller,
  ) {
    if (paymentType == "purchase") {
      controller.purchaseBook(book);
    }

    /// Close summary screen before Razorpay opens
    Navigator.of(context).pop();
  }
}
