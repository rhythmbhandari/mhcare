import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diagnosis.dart';
import 'conversationTile.dart';

// Diagnosis card widget
class DiagnosisCard extends StatelessWidget {
  final Diagnosis diagnosis;

  const DiagnosisCard({Key? key, required this.diagnosis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 4), // Shadow position
            blurRadius: 8, // Shadow blur effect
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getRandomColor(), // Random color for the icon background
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                // First letter of the doctor's name or 'D' if the name is empty

                diagnosis.doctorName.isNotEmpty ? diagnosis.doctorName[0] : 'D',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diagnosis.diagnosis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueGrey[800],
                  ),
                ),
                if (diagnosis.desc != null && diagnosis.desc!.isNotEmpty)
                  const SizedBox(height: 8),
                if (diagnosis.desc != null && diagnosis.desc!.isNotEmpty)
                  Text(
                    diagnosis.desc ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Doctor: ${diagnosis.doctorName}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                ),
                const SizedBox(height: 4),
                // Diagnosis date formatted

                Text(
                  'Date: ${DateFormat('MMMM d, yyyy – h:mm a').format(diagnosis.diagnosisDate.toLocal())}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
