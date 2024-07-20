import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/authService.dart';
import '../../services/databaseService.dart';
import '../../utils/string_utils.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  Future<UserModel?> _fetchUser() async {
    return await SharedPreferenceService().getUser();
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.of(context).popAndPushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            final user = snapshot.data!;
            final avatarText =
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          avatarText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.idNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${capitalizeFirstLetter(user.role)}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const Expanded(child: SizedBox(height: 24)),
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
