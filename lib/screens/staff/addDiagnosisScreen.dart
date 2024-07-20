import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddDiagnosisScreen extends StatefulWidget {
  final String patientNumber;

  AddDiagnosisScreen({required this.patientNumber});

  @override
  _AddDiagnosisScreenState createState() => _AddDiagnosisScreenState();
}

class _AddDiagnosisScreenState extends State<AddDiagnosisScreen> {
  final _diagnosisController = TextEditingController();
  String? _selectedDoctorId;
  List<Map<String, dynamic>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final response = await Supabase.instance.client
          .from('users') // Adjust table name as necessary
          .select('id_number, name')
          .eq('role', 'doctor');

      if (response != null) {
        setState(() {
          _doctors = List<Map<String, dynamic>>.from(response as List);
          // Set initial value if the list is not empty
          if (_doctors.isNotEmpty) {
            _selectedDoctorId = _doctors[0]['id'];
          } else {
            _selectedDoctorId = null; // No doctors available
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching doctors: ${response}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _addDiagnosis() async {
    final diagnosis = _diagnosisController.text.trim();

    if (_selectedDoctorId == null || diagnosis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      await Supabase.instance.client.from('diagnoses').insert({
        'patient_number': widget.patientNumber,
        'doctor_number': _selectedDoctorId,
        'diagnosis': diagnosis,
        'diagnosis_date':
            DateTime.now().toUtc().toIso8601String(), // Set current timestamp
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Diagnosis added successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Diagnosis'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDoctorId,
              decoration: InputDecoration(labelText: 'Select Doctor'),
              items: _doctors.map((doctor) {
                return DropdownMenuItem<String>(
                  value: doctor['id_number'] as String,
                  child: Text(doctor['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDoctorId = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a doctor' : null,
            ),
            TextFormField(
              controller: _diagnosisController,
              decoration: InputDecoration(labelText: 'Diagnosis'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addDiagnosis,
              child: Text('Add Diagnosis'),
            ),
          ],
        ),
      ),
    );
  }
}
