// import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final supabase = Supabase.instance.client;

//   Future<String?> login(String email, String password) async {
//     final response = await supabase.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );

//     if (response.error == null) {
//       final user = response.user!;
//       final userData = await supabase
//           .from('users')
//           .select('user_type')
//           .eq('id', user.id)
//           .single()
//           .execute();
//       return userData.data['user_type'];
//     } else {
//       return null;
//     }
//   }
// }
