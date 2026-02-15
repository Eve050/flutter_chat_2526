import '../../../auth/domain/entities/user.dart';

class Room {
  final int id;
  final List<User> participants;

  Room({required this.id, required this.participants});
}
