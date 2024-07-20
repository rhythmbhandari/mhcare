import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'patientDetailScreen.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final response =
        await Supabase.instance.client.from('patient_details').select();
    log(response.toString());
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No patients found'));
          } else {
            final patients = snapshot.data!;

            return ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return ListTile(
                  title: Text(patient['user_name'] ?? 'No Name'),
                  subtitle:
                      Text('Patient Number: ${patient['patient_number']}'),
                  onTap: () {
                    // Handle tap to view patient details or update
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailScreen(patient: patient),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
