import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/heartMeasurement.dart';

// Hear Rate Measurement card widget
class MeasurementCard extends StatelessWidget {
  final HeartMeasurement measurement;

  const MeasurementCard({
    Key? key,
    required this.measurement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3.0, // Shadow effect
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Space elements evenly between the row
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                Text(
                  DateFormat('MMM d, yyyy – h:mm a')
                      .format(measurement.recordedAt.toLocal()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Displaying average BPM

            Text(
              'Average BPM: ${measurement.averageBpm.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            // Displaying maximum BPM

            Text(
              'Max BPM: ${measurement.maxBpm.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4.0),
            // Displaying minimum BPM

            Text(
              'Min BPM: ${measurement.minBpm.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
