import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/environment.dart';
import '../models/message_model.dart';

abstract class ChatSocketDataSource {
  Future<void> connect();
  void disconnect();
  void joinRoom(int roomId);
  void sendMessage(int roomId, String content);
  Stream<MessageModel> get messageStream;
}

class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  IO.Socket? _socket;
  bool _isConnecting = false;

  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();

  @override
  Stream<MessageModel> get messageStream => _messageController.stream;

  @override
  Future<void> connect() async {
    // Evita conexiones concurrentes
    if (_isConnecting) return;

    // Si ya está conectado, no hagas nada (idempotente)
    if (_socket != null && _socket!.connected) return;

    _isConnecting = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      // Limpia cualquier socket previo para evitar sockets "huérfanos"
      _safeDisposeSocket();

      final socket = IO.io(
        Environment.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      _socket = socket;

      // Muy importante: evita listeners duplicados
      socket.off('connect');
      socket.off('disconnect');
      socket.off('new_message');

      socket.onConnect((_) {
        print('Socket Connected');
      });

      socket.on('new_message', (data) {
        try {
          // data puede venir como Map<dynamic, dynamic>
          final map = Map<String, dynamic>.from(data as Map);
          final message = MessageModel.fromJson(map);
          _messageController.add(message);
        } catch (e) {
          print('Error parsing message: $e');
        }
      });

      socket.onDisconnect((_) => print('Socket Disconnected'));

      socket.connect();
    } finally {
      _isConnecting = false;
    }
  }

  void _safeDisposeSocket() {
    final s = _socket;
    if (s == null) return;

    try {
      s.off('connect');
      s.off('disconnect');
      s.off('new_message');
      s.disconnect();
      // Algunas versiones tienen dispose(); si no compila, bórralo.
      // s.dispose();
    } catch (_) {}

    _socket = null;
  }

  @override
  void disconnect() {
    _safeDisposeSocket();
  }

  @override
  void joinRoom(int roomId) {
    _socket?.emit('join_room', {'roomId': roomId.toString()});
  }

  @override
  void sendMessage(int roomId, String content) {
    _socket?.emit('send_message', {
      'roomId': roomId.toString(),
      'content': content,
      'type': 'TEXT',
    });
  }
}
