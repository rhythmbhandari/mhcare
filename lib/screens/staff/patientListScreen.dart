import 'package:david/services/staffService.dart';
import 'package:flutter/material.dart';

import '../../widgets/patientCard.dart';

/// A screen that displays a list of patients.
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  PatientListScreenState createState() => PatientListScreenState();
}

class PatientListScreenState extends State<PatientListScreen> {
  late Future<List<Map<String, dynamic>>> _patientsFuture;
  final StaffService _patientService = StaffService();

  @override
  void initState() {
    super.initState();
    _refreshPatients(); // Initialize the patient list fetch
  }

  /// Refreshes the list of patients.
  Future<void> _refreshPatients() async {
    setState(() {
      _patientsFuture = _patientService.fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPatients, // Trigger refresh on swipe down
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _patientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No patients found'));
            } else {
              final patients = snapshot.data!;

              return ListView.builder(
                itemCount: patients.length,
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return PatientCard(
                    patient: patient,
                    onUpdate: _refreshPatients,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
