import '../entities/message.dart';
import '../entities/room.dart';

abstract class ChatRepository {
  Future<Room> getDirectRoom(int targetUserId);

  Future<List<Message>> getChatHistory(int roomId, {int limit, int offset});

  Future<void> connectSocket();
  void disconnectSocket();
  void joinRoom(int roomId);
  void sendMessage(int roomId, String content);

  Stream<Message> get messageStream;
}
