import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipPlanModel {
  final String id;
  final String gymId;
  final String planName;
  final String duration;
  final double price;
  final List<String> features;
  final bool isActive;

  MembershipPlanModel({
    required this.id,
    required this.gymId,
    required this.planName,
    required this.duration,
    required this.price,
    required this.features,
    this.isActive = true,
  });

  String get displayPrice => "\$${price.toStringAsFixed(2)}/$duration";

  factory MembershipPlanModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MembershipPlanModel(
      id: doc.id,
      gymId: data['gymId'] ?? '',
      planName: data['planName'] ?? '',
      duration: data['duration'] ?? 'Monthly',
      price: (data['price'] ?? 0.0).toDouble(),
      features: List<String>.from(data['features'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gymId': gymId,
      'planName': planName,
      'duration': duration,
      'price': price,
      'features': features,
      'isActive': isActive,
    };
  }
}