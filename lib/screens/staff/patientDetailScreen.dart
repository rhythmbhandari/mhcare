import 'package:david/services/staffService.dart';
import 'package:david/widgets/buttonwidget.dart';
import 'package:david/widgets/customtextfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A screen for viewing and updating patient details.
class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  PatientDetailScreenState createState() => PatientDetailScreenState();
}

class PatientDetailScreenState extends State<PatientDetailScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;
  final StaffService _patientService = StaffService();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  /// Initializes the text fields with the current patient data.
  void _initializeFields() {
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

  /// Opens a date picker and updates the selected date.
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

  /// Updates the patient details in the database.
  Future<void> _updatePatientDetails() async {
    setState(() {
      _isLoading = true;
    });

    final updatedName = _nameController.text.trim();
    final updatedAddress = _addressController.text.trim();
    final updatedDob = _dobController.text.trim();
    final updatedPassword = _passwordController.text.trim();

    try {
      await _patientService.updatePatient(
        patientNumber: widget.patient['patient_number'],
        address: updatedAddress,
        dateOfBirth: updatedDob,
      );

      await _patientService.updateUser(
        idNumber: widget.patient['patient_number'],
        name: updatedName,
        password: updatedPassword.isNotEmpty ? updatedPassword : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Patient details updated successfully'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context);
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
        title: const Text('Patient Details'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Name',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
            ),
            const SizedBox(height: 10),
            _buildDateOfBirthField(),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _passwordController,
              label: 'New Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  /// Creates a text field widget.
  CustomTextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return CustomTextFormField(
      labelText: label,
      obscureText: obscureText,
      textInputType: TextInputType.text,
      textController: controller,
      inputFormatters: [],
      onChanged: (String) {},
    );
  }

  /// Creates a date of birth text field that is disabled and opens the date picker on tap.
  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: CustomTextFormField(
        labelText: 'Date of Birth',
        obscureText: false,
        textInputType: TextInputType.text,
        textController: _dobController,
        inputFormatters: [],
        enabled: false,
        onChanged: (String) {},
      ),
    );
  }

  /// Creates an update button with loading indicator.
  Widget _buildUpdateButton() {
    return ButtonsWidget(
      name: "Update Details",
      onPressed: _updatePatientDetails,
      isLoading: _isLoading,
    );
  }
}
