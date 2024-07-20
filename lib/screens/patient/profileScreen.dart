import 'package:david/services/authService.dart';
import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/patientService.dart';
import '../../utils/string_utils.dart';

// Profile Screen for Patient
class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  // Handles user logout and navigates back to the home screen
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
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: FutureBuilder<PatientModel?>(
        future: userService.fetchUser(), // Fetch user data from the service
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
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
                    const SizedBox(height: 8),
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
