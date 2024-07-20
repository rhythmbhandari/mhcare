import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  PatientDetailScreen({required this.patient});

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.patient['user_name'] ?? '';
    _addressController.text = widget.patient['address'] ?? '';
    _dobController.text = widget.patient['date_of_birth']?.toString() ?? '';
    _selectedDate = DateTime.tryParse(widget.patient['date_of_birth'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updatePatientDetails() async {
    setState(() {
      _isLoading = true;
    });

    final updatedName = _nameController.text.trim();
    final updatedAddress = _addressController.text.trim();
    final updatedDob = _dobController.text.trim();
    final updatedPassword = _passwordController.text.trim();

    try {
      final patientUpdates = {
        'address': updatedAddress,
        'date_of_birth': updatedDob,
      };

      await Supabase.instance.client
          .from('patients')
          .update(patientUpdates)
          .eq('patient_number', widget.patient['patient_number']);

      final userUpdates = {
        'name': updatedName,
        if (updatedPassword.isNotEmpty)
          'password_hash': BCrypt.hashpw(updatedPassword, BCrypt.gensalt()),
      };

      await Supabase.instance.client
          .from('users')
          .update(userUpdates)
          .eq('id_number', widget.patient['patient_number']);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Patient details updated successfully'),
        backgroundColor: Colors.green,
      ));

      // Optionally, navigate back or refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(labelText: 'Date of Birth'),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePatientDetails,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Update Details'),
            ),
          ],
        ),
      ),
    );
  }
}
