import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.content,
    required super.senderId,
    required super.senderName,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      content: json['content'] as String? ?? '',
      senderId: json['senderId'] is int
          ? json['senderId']
          : int.tryParse(json['senderId'].toString()) ?? 0,
      senderName: json['sender'] != null && json['sender']['name'] != null
          ? json['sender']['name'] as String
          : 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
