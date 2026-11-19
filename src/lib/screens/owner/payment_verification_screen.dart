// lib/screens/owner/payment_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'receipt_verification.dart';
import 'authentication.dart';

AppBar _kerepekAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
      onPressed: () => Navigator.maybePop(context),
    ),

    titleSpacing: 0,
    title: Image.asset(
      'assets/images/logo_kerepekhub.png',
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Text("KerepekHub",
        style: TextStyle(
          color: Color(0xFF222222),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: const Color(0xFFEEEEEE), height: 1),
    ),
  );
}

class PaymentVerificationScreen extends StatelessWidget {
  const PaymentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

   // Check if Business Owner is logged in
    if (!paymentProvider.ownerLogin) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _kerepekAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Color(0xFF888888)),
              const SizedBox(height: 16),
              const Text("Access Denied: Business Owner must be logged in",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  onPressed: () => paymentProvider.setOwnerLogin(true),
                  child: const Text("Business Owner",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final payments = paymentProvider.payments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _kerepekAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'Payment verification',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
          ),

          Expanded(
            child: payments.isEmpty
                ? const Center(
                    child: Text("No orders found.",
                      style: TextStyle(color: Color(0xFF777777), fontSize: 14),
                    ),
                  )
              
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return _PaymentRow(
                        payment: payment,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderReceiptScreen(payment: payment),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// One payment row in the list 
class _PaymentRow extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const _PaymentRow({required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${payment.orderID} • ${payment.customerName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),

                  const SizedBox(height: 2),
                  Text("RM${payment.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),

                  const SizedBox(height: 2),
                  Text("Order status: ${payment.orderStatus}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),

                  if (payment.rejectReason.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Reason: ${payment.rejectReason}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),
            _Status(status: payment.paymentStatus),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String status;

  const _Status ({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'Verified':
        color = const Color(0xFF2E9E5B);
        break;
      case 'Rejected':
        color = const Color(0xFFE53935);
        break;
      default:
        color = const Color(0xFF555555);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),

      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Detail screen displaying the receipt, Verify / Reject
class OrderReceiptScreen extends StatelessWidget {
  final Payment payment;

  const OrderReceiptScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _kerepekAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Verify receipt · ${payment.orderID}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 14),

            // Order summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer: ${payment.customerName}",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text("Expected total: RM${payment.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text("Payment status: ${payment.paymentStatus}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),

                  Text("Order status: ${payment.orderStatus}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text("Uploaded payment receipt",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),

            // Display receipt or corrupted error
            _receiptViewer(payment),
          ],
        ),
      ),

      // Bottom bar, same as the catalog's "View cart" bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF222222),
                    side: const BorderSide(color: Color(0xFF555555)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _rejectDialog(context, paymentProvider),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Update to Verified and move to Processing
                    paymentProvider.verifyPayment(payment.orderID);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment verified.')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptViewer(Payment payment) {
    // Error when receipt file is corrupted or unreadable
    if (payment.isReceiptCorrupted || payment.receiptURL.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE53935)),
          borderRadius: BorderRadius.circular(8),
        ),

        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 40, color: Color(0xFFE53935)),
            SizedBox(height: 10),
            Text("Receipt file is corrupted and unreadable.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE53935),
              ),
            ),

            SizedBox(height: 4),
            Text("Reject this payment and ask the customer to upload a valid file.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Color(0xFF555555)),
            ),
          ],
        ),
      );
    }

    // Display PDF receipt
    if (payment.receiptType == 'pdf') {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: Color(0xFF555555),
            ),

            const SizedBox(height: 10),
            Text(
              payment.receiptURL,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 4),
            const Text("PDF document ready for review",
              style: TextStyle(fontSize: 11.5, color: Color(0xFF555555)),
            ),
          ],
        ),
      );
    }

    // Display image receipt 
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 320,
        color: const Color(0xFFF5F5F5),
        child: Image.network(
          payment.receiptURL,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 40, color: Color(0xFFE53935)),
                    SizedBox(height: 8),
                    Text("Receipt file is corrupted and unreadable.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Dialog for rejection reason
  void _rejectDialog(BuildContext context, PaymentProvider paymentProvider) {
    final TextEditingController reasonController = TextEditingController();
    String? selectedPreset = "Amount does not match order total";

      final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF222222), width: 1.2),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Reject payment',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select or enter a reason for rejection:",
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
                  ),

                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedPreset,
                    isExpanded: true,
                    decoration: InputDecoration(
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: "Incorrect payment amount",
                        child: Text("Incorrect payment amount"),
                      ),

                      DropdownMenuItem(
                        value: "Receipt file is unclear",
                        child: Text("Receipt file is unclear"),
                      ),
                      
                      DropdownMenuItem(
                        value: "Incorrect recipient details",
                        child: Text("Incorrect recipient details")
                      ),

                      DropdownMenuItem(
                        value: "Other",
                        child: Text("Other (specify below)"),
                      ),
                    ],

                    onChanged: (val) {
                      setState(() {
                        selectedPreset = val;
                      });
                    },
                  ),
                  if (selectedPreset == "Other") ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        hintText: "Specify reason",
                        hintStyle: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 14,
                        ),

                        enabledBorder: enabledBorder,
                        focusedBorder: focusedBorder,
                      ),
                    ),
                  ],
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  onPressed: () {
                    final finalReason = selectedPreset == 'Other'
                        ? (reasonController.text.trim().isEmpty
                              ? 'Invalid receipt'
                              : reasonController.text.trim())
                        : selectedPreset!;

                    // Payment Status (Reject payment, hold order, notify customer)
                    paymentProvider.rejectPayment(payment.orderID, finalReason);

                    Navigator.pop(ctx); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment rejected.")),
                    );
                    Navigator.pop(context); // Return to list
                  },

                  child: const Text("Confirms reject",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}