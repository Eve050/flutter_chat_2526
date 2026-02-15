import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<User> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);

    final token = response['token'];
    final userJson = response['user'];

    await sharedPreferences.setString('token', token);
    await sharedPreferences.setString('user', jsonEncode(userJson));

    return UserModel.fromJson(userJson);
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('user');
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.containsKey('token');
  }

  @override
  Future<User?> getCurrentUser() async {
    final userString = sharedPreferences.getString('user');
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }
}
