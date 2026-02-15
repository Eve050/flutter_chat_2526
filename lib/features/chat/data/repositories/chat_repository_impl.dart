import '../../domain/entities/message.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_socket_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.socketDataSource,
  });

  @override
  Future<Room> getDirectRoom(int targetUserId) async {
    return await remoteDataSource.getDirectRoom(targetUserId);
  }

  @override
  Future<List<Message>> getChatHistory(
    int roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await remoteDataSource.getChatHistory(
      roomId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<void> connectSocket() async {
    await socketDataSource.connect();
  }

  @override
  void disconnectSocket() {
    socketDataSource.disconnect();
  }

  @override
  void joinRoom(int roomId) {
    socketDataSource.joinRoom(roomId);
  }

  @override
  void sendMessage(int roomId, String content) {
    socketDataSource.sendMessage(roomId, content);
  }

  @override
  Stream<Message> get messageStream => socketDataSource.messageStream;
}
