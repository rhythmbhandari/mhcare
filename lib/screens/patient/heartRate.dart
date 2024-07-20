import 'package:flutter/material.dart';
import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/databaseService.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  List<SensorValue> _sensorData = [];
  List<SensorValue> _bpmData = [];
  bool _isMeasurementActive = false;

  void _toggleMeasurement() {
    setState(() {
      _isMeasurementActive = !_isMeasurementActive;
    });
  }

  void _handleRawData(SensorValue sensorValue) {
    setState(() {
      if (_sensorData.length >= 100) _sensorData.removeAt(0);
      _sensorData.add(sensorValue);
    });
  }

  void _handleBPM(int bpmValue) {
    setState(() {
      if (_bpmData.length >= 100) _bpmData.removeAt(0);
      _bpmData
          .add(SensorValue(value: bpmValue.toDouble(), time: DateTime.now()));
    });
  }

  double? _calculateAverageBPM() {
    if (_bpmData.isEmpty) return null;
    double sum = _bpmData.fold(
        0, (previousValue, element) => previousValue + element.value);
    return sum / _bpmData.length;
  }

  num? _calculateMaxBPM() {
    if (_bpmData.isEmpty) return null;
    return _bpmData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  num? _calculateMinBPM() {
    if (_bpmData.isEmpty) return null;
    return _bpmData.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  }

  void _uploadData() async {
    final averageBPM = _calculateAverageBPM();
    final maxBPM = _calculateMaxBPM();
    final minBPM = _calculateMinBPM();

    if (averageBPM == null || maxBPM == null || minBPM == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data to upload')),
      );
      return;
    }

    try {
      final user = await SharedPreferenceService().getUser();

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
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
          SnackBar(content: Text('Data uploaded successfully!')),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        title: Text('Heart Rate',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
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
                          showTextValues: true,
                          borderRadius: 12,
                          onRawData: _handleRawData,
                          onBPM: _handleBPM,
                        ),
                      )
                    : Container(),
                Expanded(
                  child: latestBPM != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
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
                        offset: Offset(0, 2))
                  ],
                ),
                height: 180,
                child: BPMChart(_sensorData),
              ),
            if (averageBPM != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
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
                        offset: Offset(0, 2))
                  ],
                ),
                constraints: BoxConstraints.expand(height: 180),
                child: BPMChart(_bpmData),
              ),
            if (maxBPM != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
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
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
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
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.favorite_rounded),
                label: Text(
                  _isMeasurementActive
                      ? "Stop Measurement"
                      : "Start Measurement",
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _toggleMeasurement,
              ),
            ),
            if (averageBPM != null && !_isMeasurementActive)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Upload Data',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}