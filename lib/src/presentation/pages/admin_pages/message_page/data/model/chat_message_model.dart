import 'dart:convert';

class ChatMessageModel {
  final String id;
  final String text;
  final String time;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
  });

  ChatMessageModel copyWith({
    String? id,
    String? text,
    String? time,
    bool? isMe,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "text": text,
      "time": time,
      "isMe": isMe,
    };
  }

  String toJson() => json.encode(toMap());

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map["id"] as String,
      text: map["text"] as String,
      time: map["time"] as String,
      isMe: map["isMe"] as bool,
    );
  }

  factory ChatMessageModel.fromJson(String source) {
    return ChatMessageModel.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(covariant ChatMessageModel other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.text == text &&
        other.time == time &&
        other.isMe == isMe;
  }
  
  @override
  int get hashCode => id.hashCode^text.hashCode^time.hashCode^isMe.hashCode;
  
}
