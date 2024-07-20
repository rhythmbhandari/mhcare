import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/patient.dart';
import '../../services/authService.dart';
import '../../services/databaseService.dart';
import '../../utils/string_utils.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  Future<PatientModel?> _fetchUser() async {
    final user = await SharedPreferenceService().getUser();
    if (user == null) {
      throw Exception('User not found');
    }

    final response = await Supabase.instance.client
        .from('patients')
        .select()
        .eq('patient_number', user.idNumber)
        .single();
    final Map<String, dynamic> data = response;

    final result = PatientModel.fromJson({
      'id_number': user.idNumber,
      'password_hash': user.passwordHash,
      'role': user.role,
      'name': user.name,
      'address': data['address'],
      'date_of_birth': data['date_of_birth'],
    });
    return result;
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
        backgroundColor:
            Colors.blueGrey[800], // Updated color for professionalism
      ),
      body: FutureBuilder<PatientModel?>(
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors
                          .blueGrey[200], // Updated color for professionalism
                      child: Text(
                        avatarText.toUpperCase(),
                        style: TextStyle(
                            color: Colors.blueGrey[800], fontSize: 36),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors
                            .blueGrey[800], // Updated color for professionalism
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user.name ?? 'No name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors
                            .blueGrey[600], // Updated color for professionalism
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Role: ${capitalizeFirstLetter(user.role)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors
                            .blueGrey[600], // Updated color for professionalism
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Address: ${user.address ?? 'No address'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors
                            .blueGrey[600], // Updated color for professionalism
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date of Birth: ${user.dateOfBirth}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors
                            .blueGrey[600], // Updated color for professionalism
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(
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
