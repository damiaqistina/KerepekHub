import 'package:flutter/material.dart';
import 'package:kerepekhub/screens/owner/receipt_verification.dart';

class PaymentProvider extends ChangeNotifier {
  // Precondition 1: Business owner must be login
  bool _ownerLogin = true;
  bool get ownerLogin => _ownerLogin; // Public getter

  void setOwnerLogin(bool status) {
    _ownerLogin = status;
    notifyListeners();
  }
  
  // Demo already verified (Aisyah)
  PaymentProvider() {
    _payments[0].paymentStatus = "Verified";
    _payments[0].orderStatus = "Processing";
    _payments[0].verifiedAt = "9 Nov 2026, 10:00 am";
    _payments[0].customerNotification = "Your payment for A001 has been verified. Order is now Processing. Thank you for your purchase.";
  }
  // Sample orders for testing
  final List<Payment> _payments = [
    // Valid image receipt
    Payment("#CNM-01", "A001", "Siti Aisyah", 20.00, "aisyah_receipt.png", "image", false,
    ),

    // pdf receipt
    Payment("#CNM-02", "A002", "Adira Rahima", 10.00, "adira_receipt.pdf", "pdf", true,
    ),

    // Corrupted receipt
    Payment("#CNM-03", "A003", "Nic Co", 25.00, "nicco_receipt.png", "image", true,
    ),
  ];

  List<Payment> get payments => _payments;

  // Verify payment
  void verifyPayment(String orderID) {
    final index = _payments.indexWhere((p) => p.orderID == orderID);
    if (index == -1) return;

    _payments[index].paymentStatus = "Verified";
    _payments[index].orderStatus = "Processing";
    _payments[index].verifiedAt = DateTime.now().toString();
    _payments[index].rejectReason = " ";
    _payments[index].customerNotification =
        "Your payment for $orderID has been verified. Order is now Processing. Thank you for your purchased.";
    notifyListeners();
  }

  // Hold order for invalid receipt and notify customers
  void rejectPayment(String orderID, String reason) {
    final index = _payments.indexWhere((p) => p.orderID == orderID);
    if (index == -1) return;

    _payments[index].paymentStatus = "Rejected";
    _payments[index].orderStatus = "On Hold";
    _payments[index].rejectReason = reason;
    _payments[index].customerNotification =
        "Your payment for $orderID is rejected due to ($reason). Please re-upload a valid receipt. Thank you";
    notifyListeners();
  }
}
