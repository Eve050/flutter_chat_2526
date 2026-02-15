import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/message_model.dart';
import '../models/room_model.dart';

abstract class ChatRemoteDataSource {
  Future<RoomModel> getDirectRoom(int targetUserId);
  Future<List<MessageModel>> getChatHistory(
    int roomId, {
    int limit = 50,
    int offset = 0,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient dioClient;

  ChatRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<RoomModel> getDirectRoom(int targetUserId) async {
    try {
      final response = await dioClient.dio.post(
        '/api/chat/direct',
        data: {'targetUserId': targetUserId},
      );
      return RoomModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get room');
    }
  }

  @override
  Future<List<MessageModel>> getChatHistory(
    int roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/api/chat/history/$roomId',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final List<dynamic> list = response.data;
      return list.map((e) => MessageModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get history');
    }
  }
}
