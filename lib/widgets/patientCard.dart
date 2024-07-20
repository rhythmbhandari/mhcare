import 'package:flutter/material.dart';

import '../screens/patient/heartRateHistoryScreen.dart';
import '../screens/staff/addDiagnosisScreen.dart';
import '../screens/staff/patientDetailScreen.dart';
import '../screens/staff/sendMessageScreen.dart';
import '../services/databaseService.dart';
import 'conversationTile.dart';

//Card component for patient list
class PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onUpdate;

  const PatientCard({
    Key? key,
    required this.patient,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getRandomColor(),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                patient['user_name']?.substring(0, 1) ?? 'N',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            patient['user_name'] ?? 'No Name',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Patient Number: ${patient['patient_number']}',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.info, color: Colors.black38),
            onPressed: () async {
              // Navigate to the PatientDetailScreen and refresh the data when coming back
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(
                    patient: patient,
                  ),
                ),
              );
              onUpdate();
            },
          ),
        ),
        _buildActions(context), // Add action buttons below the ListTile
      ]),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () async {
            // Navigate to the HeartMeasurementsScreen and refresh the data when coming back

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeartMeasurementsScreen(
                  patientId: patient['patient_number'],
                ),
              ),
            );
            onUpdate();
          },
        ),
        IconButton(
          icon: Icon(Icons.local_hospital, color: Colors.teal.shade800),
          onPressed: () async {
            // Navigate to the AddDiagnosisScreen and refresh the data when coming back

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDiagnosisScreen(
                  patientNumber: patient['patient_number'],
                ),
              ),
            );
            onUpdate(); // Refresh the list when coming back
          },
        ),
        IconButton(
          icon: Icon(Icons.message, color: Colors.blue.shade800),
          onPressed: () async {
            // Fetch the sender number from shared preferences

            final senderNumber = await SharedPreferenceService().getUser();
            if (senderNumber != null) {
              // Navigate to the ChatScreen and refresh the data when coming back

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    patientNumber: patient['patient_number'],
                    patientName: patient['user_name'],
                    senderNumber: senderNumber.idNumber,
                  ),
                ),
              );
              onUpdate();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to get sender ID'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
