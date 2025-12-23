// /// Enum to represent the current status of a member's subscription.
// enum MembershipStatus { active, inactive, expired }

// /// A data class to represent a single weight data point for the progress chart.
// class WeightData {
//   final DateTime month;
//   final double weight;

//   WeightData({required this.month, required this.weight});
// }

// // --- Main Member Model ---

// /// A comprehensive data model for a gym member.
// class Member {
//   final String name;
//   final String membershipId;
//   final String imageUrl;
//   final MembershipStatus status;
//   final DateTime joinDate;
//   final DateTime expiryDate;

//   // Membership Stats
//   final String membershipType;
//   final List<String> planFeatures;
//   final DateTime lastPaymentDate;
//   final DateTime nextPaymentDue;

//   // Attendance Stats
//   final DateTime lastVisitedDate;
//   final int totalVisitsThisMonth;
//   final int classesEnrolled;

//   // Progress Stats
//   final String fitnessGoal;
//   final List<WeightData> progressData; // For the chart
//   final List<String> achievements;

//   Member({
//     required this.name,
//     required this.membershipId,
//     required this.imageUrl,
//     required this.status,
//     required this.joinDate,
//     required this.expiryDate,
//     required this.membershipType,
//     required this.planFeatures,
//     required this.lastPaymentDate,
//     required this.nextPaymentDue,
//     required this.lastVisitedDate,
//     required this.totalVisitsThisMonth,
//     required this.classesEnrolled,
//     required this.fitnessGoal,
//     required this.progressData,
//     required this.achievements,
//   });
// }

// // --- Dummy Data ---

// /// A list of pre-populated [Member] objects for testing and UI development.
// /// Note: Make sure the corresponding image assets exist in your `assets/images/` directory.




