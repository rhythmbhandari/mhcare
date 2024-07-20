import 'package:david/widgets/buttonwidget.dart';
import 'package:flutter/material.dart';
import '../../services/staffService.dart';
import '../../widgets/customtextfield.dart';

class AddDiagnosisScreen extends StatefulWidget {
  final String patientNumber;

  const AddDiagnosisScreen({required this.patientNumber, Key? key})
      : super(key: key);

  @override
  AddDiagnosisScreenState createState() => AddDiagnosisScreenState();
}

class AddDiagnosisScreenState extends State<AddDiagnosisScreen> {
  final _diagnosisController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedDoctorId;
  List<Map<String, dynamic>> _doctors = [];
  final StaffService _diagnosisService = StaffService();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctors = await _diagnosisService.fetchDoctors();
      setState(() {
        _doctors = doctors;
        _selectedDoctorId =
            _doctors.isNotEmpty ? _doctors[0]['id_number'] : null;
      });
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _addDiagnosis() async {
    final diagnosis = _diagnosisController.text.trim();
    final description = _descriptionController.text.trim();

    if (_selectedDoctorId == null || diagnosis.isEmpty) {
      _showErrorSnackBar('Please fill out all fields');
      return;
    }

    try {
      await _diagnosisService.addDiagnosis(
        patientNumber: widget.patientNumber,
        doctorNumber: _selectedDoctorId!,
        diagnosis: diagnosis,
        description: description,
      );
      _showSuccessSnackBar('Diagnosis added successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Diagnosis'),
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedDoctorId,
                hint: const Text('Select Doctor'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDoctorId = newValue;
                  });
                },
                isExpanded: true,
                underline: const SizedBox(),
                items: _doctors.map((doctor) {
                  return DropdownMenuItem<String>(
                    value: doctor['id_number'] as String,
                    child: Text(
                      doctor['name'] as String,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.black87),
                    ),
                  );
                }).toList(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black87),
                dropdownColor: Colors.white,
              ),
            ),
            SizedBox(height: 18),
            CustomTextFormField(
              labelText: 'Diagnosis',
              textController: _diagnosisController,
              onChanged: (_) {},
              readOnly: false,
              textInputType: TextInputType.name,
              inputFormatters: [],
              color: Colors.white54,
              obscureText: false,
            ),
            SizedBox(height: 18),
            CustomTextFormField(
              labelText: 'Description',
              textController: _descriptionController,
              onChanged: (_) {},
              readOnly: false,
              textInputType: TextInputType.name,
              inputFormatters: [],
              color: Colors.white54,
              obscureText: false,
            ),
            const SizedBox(height: 32),
            ButtonsWidget(onPressed: _addDiagnosis, name: 'Add Diagnosis'),
          ],
        ),
      ),
    );
  }
}
