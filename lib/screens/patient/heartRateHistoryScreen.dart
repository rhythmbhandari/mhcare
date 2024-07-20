import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/heartMeasurement.dart';
import '../../services/databaseService.dart';

class HeartMeasurementsScreen extends StatefulWidget {
  const HeartMeasurementsScreen({super.key});

  @override
  HeartMeasurementsScreenState createState() => HeartMeasurementsScreenState();
}

class HeartMeasurementsScreenState extends State<HeartMeasurementsScreen> {
  late Future<List<HeartMeasurement>> _measurementsFuture;

  @override
  void initState() {
    super.initState();
    _measurementsFuture = _fetchMeasurements();
  }

  Future<List<HeartMeasurement>> _fetchMeasurements() async {
    final patient = await SharedPreferenceService().getUser();
    if (patient == null) {
      throw Exception('User not found');
    }
    final response = await Supabase.instance.client
        .from('heartratemeasurements')
        .select('*')
        .eq('patient_id', patient.idNumber)
        .order('recorded_at', ascending: false);

    log(response.toString());

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response as List<dynamic>);

    return data.map((map) => HeartMeasurement.fromMap(map)).toList();
  }

  Future<void> _refreshMeasurements() async {
    setState(() {
      _measurementsFuture = _fetchMeasurements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Measurements'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshMeasurements,
          ),
        ],
      ),
      body: FutureBuilder<List<HeartMeasurement>>(
        future: _measurementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching measurements. ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No measurements available.'));
          } else {
            final measurements = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshMeasurements,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.favorite, color: Colors.red),
                              Text(
                                DateFormat('MMM d, yyyy – h:mm a')
                                    .format(measurement.recordedAt.toLocal()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Average BPM: ${measurement.averageBpm.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Max BPM: ${measurement.maxBpm.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Min BPM: ${measurement.minBpm.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
