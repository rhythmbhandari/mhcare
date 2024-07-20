import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/diagnosis.dart';
import '../../services/databaseService.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  late Future<List<Diagnosis>> _diagnosesFuture;

  @override
  void initState() {
    super.initState();
    _diagnosesFuture = _fetchDiagnoses();
  }

  Future<List<Diagnosis>> _fetchDiagnoses() async {
    final patient = await SharedPreferenceService().getUser();
    if (patient == null) {
      throw Exception('User not found');
    }
    final response = await Supabase.instance.client
        .from('diagnoses')
        .select('*, user:doctor_number(id_number, name)')
        .eq('patient_number', patient.idNumber)
        .order('diagnosis_date', ascending: false);

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);

    return data.map((e) {
      final doctor = e['user'];
      return Diagnosis(
        id: e['id'],
        patientNumber: e['patient_number'],
        doctorNumber: e['doctor_number'],
        diagnosis: e['diagnosis'],
        desc: e['desc'] ?? "",
        diagnosisDate: DateTime.parse(e['diagnosis_date']),
        doctorName: doctor['name'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnoses'),
        backgroundColor: Colors.blueGrey[800], // Updated color
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Diagnosis>>(
        future: _diagnosesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching diagnoses. Please try again later.',
                    style: TextStyle(color: Colors.red[700])));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No diagnoses available at this time.'));
          } else {
            final diagnoses = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: diagnoses.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 32, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final diagnosis = diagnoses[index];
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Updated color for minimalistic look
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueGrey[100], // Updated color
                        child: Text(
                          diagnosis.doctorName.isNotEmpty
                              ? diagnosis.doctorName[0]
                              : 'D',
                          style: TextStyle(
                            color: Colors.blueGrey[800], // Updated color
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diagnosis.diagnosis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blueGrey[800], // Updated color
                              ),
                            ),
                            if (diagnosis.desc != null &&
                                diagnosis.desc!.isNotEmpty)
                              SizedBox(height: 8),
                            if (diagnosis.desc != null &&
                                diagnosis.desc!.isNotEmpty)
                              Text(
                                diagnosis.desc!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey[600], // Updated color
                                ),
                              ),
                            SizedBox(height: 8),
                            Text(
                              'Doctor: ${diagnosis.doctorName}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey[600], // Updated color
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Date: ${DateFormat('MMMM d, yyyy – h:mm a').format(diagnosis.diagnosisDate.toLocal())}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey[500], // Updated color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
