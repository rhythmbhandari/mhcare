import 'package:david/widgets/buttonwidget.dart';
import 'package:flutter/material.dart';
import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/databaseService.dart';

/// Screen for measuring heart rate.
/// package used: https://pub.dev/packages/heart_bpm
/// example reference: https://github.com/kvedala/heart_bpm/tree/main/example
class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  final List<SensorValue> _sensorData = []; // List to store raw sensor data
  final List<SensorValue> _bpmData = []; // List to store processed BPM data
  bool _isMeasurementActive = false; // State to track if measurement is active

  // Toggles the state of measurement (active/inactive)
  void _toggleMeasurement() {
    setState(() {
      _isMeasurementActive = !_isMeasurementActive;
    });
  }

  // Handles raw sensor data and updates the state
  void _handleRawData(SensorValue sensorValue) {
    setState(() {
      if (_sensorData.length >= 100) _sensorData.removeAt(0);
      _sensorData.add(sensorValue);
    });
  }

  // Handles BPM values and updates the state
  void _handleBPM(int bpmValue) {
    setState(() {
      if (_bpmData.length >= 100) _bpmData.removeAt(0);
      _bpmData
          .add(SensorValue(value: bpmValue.toDouble(), time: DateTime.now()));
    });
  }

  // Calculates the average BPM from the collected data
  double? _calculateAverageBPM() {
    if (_bpmData.isEmpty) return null;
    double sum = _bpmData.fold(
        0, (previousValue, element) => previousValue + element.value);
    return sum / _bpmData.length;
  }

  // Calculates the maximum BPM from the collected data
  num? _calculateMaxBPM() {
    if (_bpmData.isEmpty) return null;
    return _bpmData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  // Calculates the minimum BPM from the collected data
  num? _calculateMinBPM() {
    if (_bpmData.isEmpty) return null;
    return _bpmData.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  }

  // Uploads the calculated BPM data to the server
  void _uploadData() async {
    final averageBPM = _calculateAverageBPM();
    final maxBPM = _calculateMaxBPM();
    final minBPM = _calculateMinBPM();

    if (averageBPM == null || maxBPM == null || minBPM == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to upload')),
      );
      return;
    }

    try {
      final user = await SharedPreferenceService().getUser();

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      final response =
          await Supabase.instance.client.from('heartratemeasurements').insert({
        'patient_id': user.idNumber,
        'average_bpm': averageBPM,
        'max_bpm': maxBPM,
        'min_bpm': minBPM,
      });

      if (response == null) {
        setState(() {
          _bpmData.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data uploaded successfully!')),
        );
      } else {
        throw response;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data: ${e.toString()}')),
      );
    }
  }

  // Navigates to the history screen
  void _goToHistoryScreen() async {
    Navigator.pushNamed(context, '/measurement_history');
  }

  @override
  Widget build(BuildContext context) {
    final latestBPM = _bpmData.isNotEmpty ? _bpmData.last.value : null;
    final averageBPM = _calculateAverageBPM();
    final maxBPM = _calculateMaxBPM();
    final minBPM = _calculateMinBPM();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _goToHistoryScreen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _isMeasurementActive
                    ? Expanded(
                        child: HeartBPMDialog(
                          context: context,
                          showTextValues: false,
                          borderRadius: 12,
                          onRawData: _handleRawData,
                          onBPM: _handleBPM,
                        ),
                      )
                    : Container(), // Show measurement dialog only if active
                Expanded(
                  child: latestBPM != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: const Text(
                                'Last Heart Rate Measurement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              subtitle: Text(
                                '${latestBPM.toStringAsFixed(1)} BPM',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
            if (_isMeasurementActive && _sensorData.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueGrey[800] ?? Colors.black,
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                height: 180,
                child: BPMChart(_sensorData), // Display sensor data chart
              ),
            if (averageBPM != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text(
                      'Average Heart Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      '${averageBPM.toStringAsFixed(1)} BPM',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            if (_isMeasurementActive && _bpmData.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueGrey[800] ?? Colors.black,
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                constraints: const BoxConstraints.expand(height: 180),
                child: BPMChart(_bpmData), // Display BPM data chart
              ),
            if (maxBPM != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text(
                      'Maximum Heart Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      '${maxBPM.toStringAsFixed(1)} BPM',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            if (minBPM != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text(
                      'Minimum Heart Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      '${minBPM.toStringAsFixed(1)} BPM',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ButtonsWidget(
                name: _isMeasurementActive
                    ? "Stop Measurement"
                    : "Start Measurement",
                onPressed: _toggleMeasurement,
              ),
            ),
            if (averageBPM != null && !_isMeasurementActive)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: ButtonsWidget(
                    name: 'Upload Heart Rate',
                    onPressed: _uploadData, // Upload data when button pressed
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
