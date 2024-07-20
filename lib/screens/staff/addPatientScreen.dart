import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bcrypt/bcrypt.dart';

import '../../models/user.dart';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _patientNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _patientNumberController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _addPatient() async {
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final dateOfBirth = _dobController.text.trim();

    if (password.isEmpty ||
        name.isEmpty ||
        address.isEmpty ||
        dateOfBirth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    try {
      final userResponse = await Supabase.instance.client.from('users').insert({
        'password_hash': hashedPassword,
        'name': name,
        'role': "patient",
      }).select();

      final addedUser = UserModel.fromJson(userResponse[0]);

      final patientResponse =
          await Supabase.instance.client.from('patients').insert({
        'patient_number': addedUser.idNumber,
        'address': address,
        'date_of_birth': dateOfBirth,
      });

      if (patientResponse == null) {
        _patientNumberController.clear();
        _passwordController.clear();
        _nameController.clear();
        _addressController.clear();
        _dobController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Patient added successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding patient'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Patient'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addPatient,
              child: Text('Add Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
