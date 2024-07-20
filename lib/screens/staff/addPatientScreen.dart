import 'package:david/widgets/buttonwidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/staffService.dart';
import '../../widgets/customtextfield.dart';

/// A screen for adding new patients.
class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  AddPatientScreenState createState() => AddPatientScreenState();
}

class AddPatientScreenState extends State<AddPatientScreen> {
  final _patientNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  // Default to current date for DatePicker
  DateTime _selectedDate = DateTime.now();
  final StaffService _patientService = StaffService();

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
    // Collect data from the text fields

    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final dateOfBirth = _dobController.text.trim();

    if (password.isEmpty ||
        name.isEmpty ||
        address.isEmpty ||
        dateOfBirth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill out all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Add a new user and patient

      final addedUser = await _patientService.addUser(
        password: password,
        name: name,
        role: "patient",
      );

      await _patientService.addPatient(
        patientNumber: addedUser.idNumber,
        address: address,
        dateOfBirth: dateOfBirth,
      );

      // Clear all text fields
      _patientNumberController.clear();
      _passwordController.clear();
      _nameController.clear();
      _addressController.clear();
      _dobController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Patient added successfully'),
        backgroundColor: Colors.green,
      ));
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
        title: const Text('Add Patient'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextFormField(
              labelText: 'Name',
              textController: _nameController,
              onChanged: (_) {},
              readOnly: false,
              textInputType: TextInputType.name,
              inputFormatters: [],
              color: Colors.white54,
              obscureText: false,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Password',
              textController: _passwordController,
              onChanged: (_) {},
              readOnly: false,
              inputFormatters: [],
              color: Colors.white54,
              textInputType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Address',
              textController: _addressController,
              onChanged: (_) {},
              readOnly: false,
              obscureText: false,
              color: Colors.white54,
              inputFormatters: [],
              textInputType: TextInputType.streetAddress,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: CustomTextFormField(
                  labelText: 'Date of Birth',
                  textController: _dobController,
                  textInputType: TextInputType.datetime,
                  onChanged: (_) {},
                  readOnly: true,
                  color: Colors.white54,
                  inputFormatters: null,
                  obscureText: false,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ButtonsWidget(
              onPressed: _addPatient,
              name: 'Add Patient',
            ),
          ],
        ),
      ),
    );
  }
}
