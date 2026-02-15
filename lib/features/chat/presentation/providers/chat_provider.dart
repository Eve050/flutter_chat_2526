import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository chatRepository;

  List<Message> _messages = [];
  final Set<int> _messageIds = {}; // ✅ dedup por id

  Room? _currentRoom;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _messageSubscription;

  ChatProvider({required this.chatRepository});

  List<Message> get messages => _messages;
  Room? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initChat(int targetUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1) Get or Create Room
      _currentRoom = await chatRepository.getDirectRoom(targetUserId);

      // 2) Connect socket (await para evitar race condition)
      await chatRepository.connectSocket();

      // 3) Join room
      chatRepository.joinRoom(_currentRoom!.id);

      // 4) Load history
      final history = await chatRepository.getChatHistory(_currentRoom!.id);
      final ordered = history.reversed.toList();

      _messages = ordered;
      _messageIds
        ..clear()
        ..addAll(ordered.map((m) => m.id));

      // 5) Listen for new messages
      await _messageSubscription?.cancel();
      _messageSubscription = chatRepository.messageStream.listen((message) {
        if (message.id == 0) return; // invalid/placeholder

        // ✅ Dedup: si entra repetido por listeners/back-end, lo ignoramos
        if (_messageIds.contains(message.id)) return;

        _messageIds.add(message.id);
        _messages.add(message);
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('Chat Error: $e');
      print('Stack Trace: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void sendMessage(String content) {
    if (_currentRoom == null) {
      _error = "Room not initialized";
      notifyListeners();
      return;
    }
    chatRepository.sendMessage(_currentRoom!.id, content);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    chatRepository.disconnectSocket();
    super.dispose();
  }
}
