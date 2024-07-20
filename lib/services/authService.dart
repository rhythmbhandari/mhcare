import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';
import 'databaseService.dart';

/// Service class for handling user authentication.
class AuthService {
  final _supabase = Supabase.instance.client;

  /// Registers a new user with Supabase.
  ///
  /// Takes [name], [password], and [role] as parameters.
  /// Hashes the password and inserts the user into the 'users' table.
  /// Returns the user's ID number if registration is successful.
  Future<String?> register({
    required String name,
    required String password,
    required String role,
  }) async {
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    try {
      final response = await _supabase.from('users').insert({
        'password_hash': hashedPassword,
        'name': name,
        'role': role.toLowerCase(),
      }).select();
      if (response.isNotEmpty) {
        final idNumber = response[0]['id_number'];
        return idNumber;
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
    return null;
  }

  /// Logs in a user by verifying their credentials.
  ///
  /// Takes [idNumber] and [password] as parameters.
  /// Checks the provided password against the stored hashed password.
  /// Saves the user information to shared preferences if login is successful.
  /// Returns a [UserModel] object if login is successful.
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

  /// Logs out the current user by signing them out.
  ///
  /// Calls Supabase's sign-out method to end the user's session.
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
