import 'package:david/services/patientService.dart';
import 'package:flutter/material.dart';
import '../../models/heartMeasurement.dart';
import '../../services/databaseService.dart';
import '../../widgets/measurementCard.dart';

/// A screen for displaying heart rate measurements.
class HeartMeasurementsScreen extends StatefulWidget {
  final String? patientId;

  const HeartMeasurementsScreen({super.key, this.patientId});

  @override
  HeartMeasurementsScreenState createState() => HeartMeasurementsScreenState();
}

class HeartMeasurementsScreenState extends State<HeartMeasurementsScreen> {
  late Future<List<HeartMeasurement>> _measurementsFuture;
  final PatientService _heartMeasurementService = PatientService();

  @override
  void initState() {
    super.initState();
    // Initialize future for fetching measurements, depending on whether patientId is provided
    _fetchMeasurements(isUser: widget.patientId == null ? true : false);
    _refreshMeasurements();
  }

  // Method to fetch heart measurements based on user or specific patient
  Future<List<HeartMeasurement>> _fetchMeasurements({isUser = true}) async {
    if (isUser) {
      final patient = await SharedPreferenceService().getUser();
      if (patient == null) {
        throw Exception('User not found');
      }
      return await _heartMeasurementService.fetchMeasurements(
          patient.idNumber); // Fetch measurements for the current user
    } else {
      return await _heartMeasurementService.fetchMeasurements(
          widget.patientId!); // Fetch measurements for the specific patient
    }
  }

  // Method to refresh measurements data
  Future<void> _refreshMeasurements() async {
    setState(() {
      _measurementsFuture =
          _fetchMeasurements(isUser: widget.patientId == null ? true : false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Measurements'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshMeasurements()),
        ],
      ),
      body: FutureBuilder<List<HeartMeasurement>>(
        future: _measurementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching measurements: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No measurements available.'));
          } else {
            final measurements = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshMeasurements,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return MeasurementCard(
                      measurement:
                          measurement); // Display measurement in a card
                },
              ),
            );
          }
        },
      ),
    );
  }
}
