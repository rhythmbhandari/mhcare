import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SharedPreferenceService {
  // Private constructor
  SharedPreferenceService._privateConstructor();

  // Static instance
  static final SharedPreferenceService _instance =
      SharedPreferenceService._privateConstructor();

  // Factory constructor to return the same instance
  factory SharedPreferenceService() {
    return _instance;
  }

  // Method to get the user
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final userJson = jsonDecode(userString);
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  // Method to save the user
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userString = jsonEncode(user.toJson());
    await prefs.setString('user', userString);
  }

  // Method to remove the user
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
