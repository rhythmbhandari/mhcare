import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/databaseService.dart';
import '../../services/authService.dart';
import '../../utils/string_utils.dart'; // Assuming you have an auth service for logout

class UserInfoScreen extends StatelessWidget {
  Future<UserModel?> _fetchUser() async {
    return await SharedPreferenceService().getUser();
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService()
        .logout(); // Assuming you have a logout method in AuthService
    Navigator.of(context)
        .popAndPushNamed('/'); // Navigate to login screen after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<UserModel?>(
        future: _fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data available'));
          } else {
            final user = snapshot.data!;
            final userName = user.idNumber;
            final avatarText = user.name.isNotEmpty ? user.name[0] : 'U';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: Text(
                        avatarText.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 36),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user.name ?? 'No name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Role: ${capitalizeFirstLetter(user.role)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal[700],
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Background color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
