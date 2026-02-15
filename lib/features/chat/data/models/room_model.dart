import '../../domain/entities/room.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';

class RoomModel extends Room {
  RoomModel({required super.id, required super.participants});

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    var participantsList =
        json['participants'] as List? ?? []; // Handle null list

    List<User> participants = participantsList
        .map((i) => UserModel.fromJson(i))
        .toList();

    return RoomModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      participants: participants,
    );
  }
}
