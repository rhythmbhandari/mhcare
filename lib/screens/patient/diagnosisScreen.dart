import 'package:david/services/patientService.dart';
import 'package:flutter/material.dart';
import '../../models/diagnosis.dart';
import '../../widgets/diagnosisCard.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  DiagnosisScreenState createState() => DiagnosisScreenState();
}

class DiagnosisScreenState extends State<DiagnosisScreen> {
  late Future<List<Diagnosis>> _diagnosesFuture;
  final PatientService _diagnosisService = PatientService();

  @override
  void initState() {
    super.initState();
    _diagnosesFuture = _diagnosisService.fetchDiagnoses();
  }

  Future<void> _refreshDiagnoses() async {
    setState(() {
      _diagnosesFuture = _diagnosisService.fetchDiagnoses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnoses'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDiagnoses,
        child: FutureBuilder<List<Diagnosis>>(
          future: _diagnosesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching diagnoses. Please try again later.',
                  style: TextStyle(color: Colors.red[700]),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No diagnoses available at this time.'));
            } else {
              final diagnoses = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: diagnoses.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 32, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final diagnosis = diagnoses[index];
                  return DiagnosisCard(diagnosis: diagnosis);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
