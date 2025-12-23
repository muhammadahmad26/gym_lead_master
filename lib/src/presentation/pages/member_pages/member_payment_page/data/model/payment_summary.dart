class PaymentSummary {
  final DateTime lastPaymentDate;
  final double lastPaymentAmount;
  final DateTime nextPaymentDue;
  final double pendingAmount;

  PaymentSummary({
    required this.lastPaymentDate,
    required this.lastPaymentAmount,
    required this.nextPaymentDue,
    required this.pendingAmount,
  });
}
