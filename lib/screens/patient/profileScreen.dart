import 'package:david/services/authService.dart';
import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/patientService.dart';
import '../../utils/string_utils.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.logout();
    Navigator.of(context).popAndPushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final PatientService userService = PatientService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: FutureBuilder<PatientModel?>(
        future: userService.fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            final user = snapshot.data!;
            final avatarText = user.name.isNotEmpty ? user.name[0] : 'U';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueGrey[200],
                      child: Text(
                        avatarText.toUpperCase(),
                        style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontSize: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.idNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${capitalizeFirstLetter(user.role)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Address: ${user.address ?? 'No address'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date of Birth: ${user.dateOfBirth}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      child: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
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
