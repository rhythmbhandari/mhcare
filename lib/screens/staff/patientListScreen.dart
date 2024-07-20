import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'patientDetailScreen.dart';
import 'addDiagnosisScreen.dart'; // Import the AddDiagnosisScreen

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<List<Map<String, dynamic>>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _fetchPatients();
  }

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final response = await Supabase.instance.client
        .from('patient_details')
        .select()
        .order('patient_number', ascending: true);
    log(response.toString());
    return List<Map<String, dynamic>>.from(response as List);
  }

  void _refreshPatients() {
    setState(() {
      _patientsFuture = _fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _patientsFuture,
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
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade700,
                        child: Text(
                          patient['user_name']?.substring(0, 1) ?? 'N',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      title: Text(
                        patient['user_name'] ?? 'No Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Patient Number: ${patient['patient_number']}',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(MdiIcons.hospital, color: Colors.white),
                            onPressed: () async {
                              // Navigate to AddDiagnosisScreen
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddDiagnosisScreen(
                                    patientNumber: patient['patient_number'],
                                  ),
                                ),
                              );
                              _refreshPatients(); // Refresh the list when coming back
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.white),
                            onPressed: () async {
                              // Navigate to PatientDetailScreen
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PatientDetailScreen(patient: patient),
                                ),
                              );
                              _refreshPatients(); // Refresh the list when coming back
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}