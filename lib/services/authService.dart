// ignore: file_names
import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';
import 'databaseService.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> register({
    required String name,
    required String password,
    required String role,
  }) async {
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    try {
      await _supabase.from('users').insert({
        'password_hash': hashedPassword,
        'name': name,
        'role': role.toLowerCase(),
      });
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<UserModel?> login(
      {required String idNumber, required String password}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id_number', idNumber)
          .maybeSingle();

      if (response == null) {
        throw Exception('User does not exist');
      }

      final user = UserModel.fromJson(response);
      final storedPasswordHash = user.passwordHash;

      if (BCrypt.checkpw(password, storedPasswordHash)) {
        SharedPreferenceService().saveUser(user);
        return user;
      } else {
        throw Exception('Invalid password');
      }
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
