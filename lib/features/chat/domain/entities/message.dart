class Message {
  final int id;
  final String content;
  final int senderId;
  final String senderName;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });
}
