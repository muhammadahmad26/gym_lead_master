import 'dart:convert';

class GymMembersData {
  String totalMembers;
  String membersDoingChestExercise;
  String membersDoingLegExercise;
  String membersDoingTricepsExercise;
  String membersDoingBicepsExercise;
  String membersDoingCardioExercise;
  String membersDoingWeightLossExercise;
  GymMembersData({
    required this.totalMembers,
    required this.membersDoingChestExercise,
    required this.membersDoingLegExercise,
    required this.membersDoingTricepsExercise,
    required this.membersDoingBicepsExercise,
    required this.membersDoingCardioExercise,
    required this.membersDoingWeightLossExercise,
  });
  GymMembersData copyWith({
    String? totalMembers,
    String? membersDoingChestExercise,
    String? membersDoingLegExercise,
    String? membersDoingTricepsExercise,
    String? membersDoingBicepsExercise,
    String? membersDoingCardioExercise,
    String? membersDoingWeightLossExercise,
  }) {
    return GymMembersData(
      totalMembers: totalMembers ?? this.totalMembers,
      membersDoingChestExercise:
          membersDoingChestExercise ?? this.membersDoingChestExercise,
      membersDoingLegExercise:
          membersDoingLegExercise ?? this.membersDoingLegExercise,
      membersDoingTricepsExercise:
          membersDoingTricepsExercise ?? this.membersDoingTricepsExercise,
      membersDoingBicepsExercise:
          membersDoingBicepsExercise ?? this.membersDoingBicepsExercise,
      membersDoingCardioExercise:
          membersDoingCardioExercise ?? this.membersDoingCardioExercise,
      membersDoingWeightLossExercise:
          membersDoingWeightLossExercise ?? this.membersDoingWeightLossExercise,
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'TotalMembers': totalMembers,
      'membersDoingChestExercise': membersDoingChestExercise,
      'membersDoingLegExercise': membersDoingLegExercise,
      'membersDoingTricepsExercise': membersDoingTricepsExercise,
      'membersDoingBicepsExercise': membersDoingBicepsExercise,
      'membersDoingCardioExercise': membersDoingCardioExercise,
      'membersDoingWeightLossExercise': membersDoingWeightLossExercise,
    };
  }
  factory GymMembersData.fromMap(Map<String, dynamic> map) {
    return GymMembersData(
      totalMembers: map['TotalMembers'] as String,
      membersDoingChestExercise: map['membersDoingChestExercise'] as String,
      membersDoingLegExercise: map['membersDoingLegExercise'] as String,
      membersDoingTricepsExercise: map['membersDoingTricepsExercise'] as String,
      membersDoingBicepsExercise: map['membersDoingBicepsExercise'] as String,
      membersDoingCardioExercise: map['membersDoingCardioExercise'] as String,
      membersDoingWeightLossExercise:
          map['membersDoingWeightLossExercise'] as String,
    );
  }
  String toJson() => json.encode(toMap());

  factory GymMembersData.fromJson(String source) =>
      GymMembersData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GymMemebersData(TotalMembers: $totalMembers, membersDoingChestExercise: $membersDoingChestExercise, membersDoingLegExercise: $membersDoingLegExercise, membersDoingTricepsExercise: $membersDoingTricepsExercise, membersDoingBicepsExercise: $membersDoingBicepsExercise, membersDoingCardioExercise: $membersDoingCardioExercise, membersDoingWeightLossExercise: $membersDoingWeightLossExercise)';
  }

  @override
  bool operator ==(covariant GymMembersData other) {
    if (identical(this, other)) return true;

    return other.totalMembers == totalMembers &&
        other.membersDoingChestExercise == membersDoingChestExercise &&
        other.membersDoingLegExercise == membersDoingLegExercise &&
        other.membersDoingTricepsExercise == membersDoingTricepsExercise &&
        other.membersDoingBicepsExercise == membersDoingBicepsExercise &&
        other.membersDoingCardioExercise == membersDoingCardioExercise &&
        other.membersDoingWeightLossExercise == membersDoingWeightLossExercise;
  }

  @override
  int get hashCode {
    return totalMembers.hashCode ^
        membersDoingChestExercise.hashCode ^
        membersDoingLegExercise.hashCode ^
        membersDoingTricepsExercise.hashCode ^
        membersDoingBicepsExercise.hashCode ^
        membersDoingCardioExercise.hashCode ^
        membersDoingWeightLossExercise.hashCode;
  }
}
