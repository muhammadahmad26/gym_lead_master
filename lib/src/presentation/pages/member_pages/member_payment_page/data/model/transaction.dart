enum TransactionStatus { paid, failed, pending }

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final String paymentMethod;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });
}