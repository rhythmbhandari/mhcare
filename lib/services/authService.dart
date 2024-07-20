import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
