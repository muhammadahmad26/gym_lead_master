import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/member_detail.dart';

final List<Member> dummyMembers = [
  // --- Member 1: Active, Premium Member ---
  Member(
    name: 'Alice Johnson',
    membershipId: 'GYM-2024-001',
    imageUrl: 'assets/images/user1.png', // Ensure this asset exists
    status: MembershipStatus.active,
    joinDate: DateTime(2023, 5, 15),
    expiryDate: DateTime(2025, 5, 14),
    membershipType: 'Premium Yearly',
    planFeatures: [
      'Unlimited Gym Access',
      'Group Fitness Classes',
      '1 Personal Training Session / Month',
      'Free Guest Passes (2/month)',
    ],
    lastPaymentDate: DateTime.now().subtract(const Duration(days: 45)),
    nextPaymentDue: DateTime.now().add(const Duration(days: 320)),
    lastVisitedDate: DateTime.now().subtract(const Duration(days: 1)),
    totalVisitsThisMonth: 18,
    classesEnrolled: 3,
    fitnessGoal: 'Muscle Gain',
    progressData: [
      WeightData(month: DateTime(2024, 1), weight: 70.5),
      WeightData(month: DateTime(2024, 2), weight: 71.2),
      WeightData(month: DateTime(2024, 3), weight: 72.0),
      WeightData(month: DateTime(2024, 4), weight: 72.8),
      WeightData(month: DateTime(2024, 5), weight: 73.5),
      WeightData(month: DateTime(2024, 6), weight: 74.1),
    ],
    achievements: ['Early Bird', '30-Day Streak', 'Class Regular', 'Power Lifter'],
  ),

  // --- Member 2: Active, Basic Member ---
  Member(
    name: 'Bob Williams',
    membershipId: 'GYM-2024-002',
    imageUrl: 'assets/images/user2.png', // Ensure this asset exists
    status: MembershipStatus.active,
    joinDate: DateTime.now().subtract(const Duration(days: 90)),
    expiryDate: DateTime.now().add(const Duration(days: 275)),
    membershipType: 'Basic Monthly',
    planFeatures: [
      'Gym Access (9 AM - 5 PM)',
      'Cardio Area',
    ],
    lastPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
    nextPaymentDue: DateTime.now().add(const Duration(days: 25)),
    lastVisitedDate: DateTime.now().subtract(const Duration(days: 3)),
    totalVisitsThisMonth: 8,
    classesEnrolled: 0,
    fitnessGoal: 'General Fitness',
    progressData: [
      WeightData(month: DateTime(2024, 3), weight: 95.0),
      WeightData(month: DateTime(2024, 4), weight: 94.2),
      WeightData(month: DateTime(2024, 5), weight: 93.8),
      WeightData(month: DateTime(2024, 6), weight: 93.0),
    ],
    achievements: ['Newcomer'],
  ),

  // --- Member 3: Inactive Member ---
  Member(
    name: 'Charlie Brown',
    membershipId: 'GYM-2023-015',
    imageUrl: 'assets/images/user3.png', // Ensure this asset exists
    status: MembershipStatus.inactive,
    joinDate: DateTime(2023, 1, 10),
    expiryDate: DateTime.now().add(const Duration(days: 15)),
    membershipType: 'Standard Quarterly',
    planFeatures: [
      'Unlimited Gym Access',
      'Sauna Access',
    ],
    lastPaymentDate: DateTime.now().subtract(const Duration(days: 75)),
    nextPaymentDue: DateTime.now().add(const Duration(days: 15)),
    lastVisitedDate: DateTime.now().subtract(const Duration(days: 60)),
    totalVisitsThisMonth: 1,
    classesEnrolled: 0,
    fitnessGoal: 'Weight Loss',
    progressData: [
      WeightData(month: DateTime(2024, 1), weight: 88.0),
      WeightData(month: DateTime(2024, 2), weight: 87.5),
      WeightData(month: DateTime(2024, 3), weight: 87.8), // Progress stalled
    ],
    achievements: ['Consistent Visitor (2023)'],
  ),

  // --- Member 4: Active, All-Access Member with lots of achievements ---
  Member(
    name: 'Diana Prince',
    membershipId: 'GYM-2022-045',
    imageUrl: 'assets/images/user4.png', // Ensure this asset exists
    status: MembershipStatus.active,
    joinDate: DateTime(2022, 11, 1),
    expiryDate: DateTime.now().add(const Duration(days: 365)),
    membershipType: 'All-Access Yearly',
    planFeatures: [
      'Unlimited Everything',
      'Personal Training (2/month)',
      'Unlimited Guest Passes',
      'Nutritionist Consultation',
    ],
    lastPaymentDate: DateTime.now().subtract(const Duration(days: 200)),
    nextPaymentDue: DateTime.now().add(const Duration(days: 165)),
    lastVisitedDate: DateTime.now().subtract(const Duration(days: 1)),
    totalVisitsThisMonth: 22,
    classesEnrolled: 5,
    fitnessGoal: 'Endurance Training',
    progressData: [
      WeightData(month: DateTime(2023, 7), weight: 65.0),
      WeightData(month: DateTime(2023, 10), weight: 64.5),
      WeightData(month: DateTime(2024, 1), weight: 64.8),
      WeightData(month: DateTime(2024, 4), weight: 64.2),
      WeightData(month: DateTime(2024, 6), weight: 63.9),
    ],
    achievements: [
      'Legend',
      '100-Day Streak',
      'Marathon Finisher',
      'Yoga Master',
      'Class Champion',
      'Top Performer 2023'
    ],
  ),
];
