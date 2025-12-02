import 'dart:convert';

class MemberModel {
  final String imagePath;
  final String name;
  final String workout;
  final String time;
  bool isHovered;
  MemberModel({
    required this.imagePath,
    required this.name,
    required this.workout,
    required this.time,
    this.isHovered = false,
  });

  MemberModel copyWith({
    String? name,
    String? workout,
    String? time,
  }) {
    return MemberModel(
      imagePath: imagePath,
      name: name ?? this.name,
      workout: workout ?? this.workout,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'name': name,
      'workout': workout,
      'time': time,
    };
  }
  String toJson() => json.encode(toMap());
  
  factory MemberModel.fromJson(String source) =>
      MemberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      imagePath: map['imagePath'],
      name: map['name'] as String,
      workout: map['workout'] as String,
      time: map['time'] as String,
    );
  }

  


  @override
  String toString() =>
      'MemberCard(imagePath: $imagePath, $name, workout: $workout, time: $time)';

  @override
  bool operator ==(covariant MemberModel other) {
    if (identical(this, other)) return true;

    return other.imagePath == imagePath &&
        other.name == name &&
        other.workout == workout &&
        other.time == time;
  }

  @override
  int get hashCode =>
      imagePath.hashCode ^ name.hashCode ^ workout.hashCode ^ time.hashCode;
}
