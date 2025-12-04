import 'dart:convert';

import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/chat_message_model.dart';

class MessagesModel {
  final String imagePath;
  final String name;
  final List<ChatMessageModel> chatMessage;
  final String time;

  final bool isHoverd;
  final String count;

  MessagesModel({
    required this.imagePath,
    required this.name,
    required this.chatMessage,
    required this.time,
    required this.count,
    this.isHoverd = false,
  });

  MessagesModel copyWith({
    String? name,
    List<ChatMessageModel>? chatMessage,
    String? time,
    String? count,
  }) {
    return MessagesModel(
      imagePath: imagePath,
      name: name ?? this.name,
      chatMessage: chatMessage ?? this.chatMessage,
      time: time ?? this.time,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "imagePath": imagePath,
      "name": name,
      "chatMessage": chatMessage,
      "time": time,
      "count": count,
    };
  }

  String toJson() => json.encode(toMap());

  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      imagePath: map["imagePath"],
      name: map["name"] as String,
      chatMessage: map["chatMessage"],
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
        other.chatMessage == chatMessage &&
        other.time == time &&
        other.count == count;
  }

  @override
  int get hashCode =>
      imagePath.hashCode ^
      name.hashCode ^
      chatMessage.hashCode ^
      time.hashCode ^
      count.hashCode;
}
