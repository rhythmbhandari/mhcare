import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diagnosis.dart';

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
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey[100],
            child: Text(
              diagnosis.doctorName.isNotEmpty ? diagnosis.doctorName[0] : 'D',
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
