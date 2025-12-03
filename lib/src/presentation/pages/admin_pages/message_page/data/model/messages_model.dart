import 'dart:convert';

class MessagesModel {
  final String imagePath;
  final String name;
  final String messageContant;
  final String time;

  final bool isHoverd;
  final String count;

  MessagesModel({
    required this.imagePath,
    required this.name,
    required this.messageContant,
    required this.time,
    required this.count,
    this.isHoverd = false,
  });

  MessagesModel copyWith({
    String? name,
    String? messageContant,
    String? time,
    String? count,
  }) {
    return MessagesModel(
      imagePath: imagePath,
      name: name ?? this.name,
      messageContant: messageContant ?? this.messageContant,
      time: time ?? this.time,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "imagePath": imagePath,
      "name": name,
      "messageContant": messageContant,
      "time": time,
      "count": count,
    };
  }

  String toJson() => json.encode(toMap());

  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      imagePath: map["imagePath"],
      name: map["name"] as String,
      messageContant: map["messageContant"] as String,
      time: map['time'] as String,
      count: map["count"] as String,
    );
  }

  factory MessagesModel.fromJson(String source) =>
      MessagesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant MessagesModel other) {
    if (identical(this, other)) return true;

    return other.imagePath == imagePath &&
        other.name == name &&
        other.messageContant == messageContant &&
        other.time == time &&
        other.count == count;
  }

  @override
  int get hashCode =>
      imagePath.hashCode ^
      name.hashCode ^
      messageContant.hashCode ^
      time.hashCode ^
      count.hashCode;
}
