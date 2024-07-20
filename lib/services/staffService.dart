import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';

// Service class for managining staff operations
class StaffService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches the list of doctors from the database.
  ///
  /// Returns a list of maps containing doctor ID numbers and names.
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    try {
      final response = await _client
          .from('users')
          .select('id_number, name')
          .eq('role', 'doctor');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Adds a new diagnosis to the database.
  ///
  /// Takes the patient number, doctor number, diagnosis, and description as required parameters.
  Future<void> addDiagnosis({
    required String patientNumber,
    required String doctorNumber,
    required String diagnosis,
    required String description,
  }) async {
    try {
      await _client.from('diagnoses').insert({
        'patient_number': patientNumber,
        'doctor_number': doctorNumber,
        'diagnosis': diagnosis,
        'desc': description,
        'diagnosis_date': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Adds a new user to the database.
  ///
  /// Takes the password, name, and role as required parameters.
  /// Returns the created [UserModel].
  Future<UserModel> addUser({
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      //Hashing the password before storing it using BCrypt: package:bcrypt/src/bcrypt_base.dart
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final response = await _client.from('users').insert({
        'password_hash': hashedPassword,
        'name': name,
        'role': role,
      }).select();

      return UserModel.fromJson(response[0]);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Adds a new patient to the database.
  ///
  /// Takes the patient number, address, and date of birth as required parameters.
  Future<void> addPatient({
    required String patientNumber,
    required String address,
    required String dateOfBirth,
  }) async {
    try {
      await _client.from('patients').insert({
        'patient_number': patientNumber,
        'address': address,
        'date_of_birth': dateOfBirth,
      });
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Updates an existing patient in the database.
  ///
  /// Takes the patient number, address, and date of birth as required parameters.
  Future<void> updatePatient({
    required String patientNumber,
    required String address,
    required String dateOfBirth,
  }) async {
    try {
      await _client.from('patients').update({
        'address': address,
        'date_of_birth': dateOfBirth,
      }).eq('patient_number', patientNumber);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Updates an existing user in the database.
  ///
  /// Takes the ID number and name as required parameters, and the password as an optional parameter.
  /// If the password is provided and not empty, it will be hashed and updated.
  Future<void> updateUser({
    required String idNumber,
    required String name,
    String? password,
  }) async {
    try {
      final userUpdates = {
        'name': name,
        if (password != null && password.isNotEmpty)
          'password_hash': BCrypt.hashpw(password, BCrypt.gensalt()),
      };

      await _client.from('users').update(userUpdates).eq('id_number', idNumber);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Fetches the list of patients from the database.
  ///
  /// Returns a list of maps containing patient details.
  Future<List<Map<String, dynamic>>> fetchPatients() async {
    try {
      final response = await _client
          .from('patient_details')
          .select()
          .order('patient_number', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
