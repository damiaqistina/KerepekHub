class Payment {
  Payment(
    this.paymentID,
    this.orderID,
    this.customerName,
    this.amount,
    this.receiptURL,
    this.receiptType, // "image", "pdf", "none"
    this.isReceiptCorrupted,
  );

  final String paymentID;
  final String orderID;
  final String customerName;
  final double amount;
  final String receiptURL;
  final String receiptType;
  final bool isReceiptCorrupted;

  String paymentStatus = "Pending verification";
  String orderStatus = "Pending";
  String verifiedAt = "";
  String rejectReason = "";
  String customerNotification = "";
}
