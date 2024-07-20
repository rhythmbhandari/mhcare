import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diagnosis.dart';
import '../models/heartMeasurement.dart';
import '../models/message.dart';
import '../models/patient.dart';
import 'databaseService.dart';

class PatientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Diagnosis>> fetchDiagnoses() async {
    final patient = await SharedPreferenceService().getUser();
    if (patient == null) {
      throw Exception('User not found');
    }
    final response = await _supabase
        .from('diagnoses')
        .select('*, user:doctor_number(id_number, name)')
        .eq('patient_number', patient.idNumber)
        .order('diagnosis_date', ascending: false);

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);

    return data.map((e) {
      final doctor = e['user'];
      return Diagnosis(
        id: e['id'],
        patientNumber: e['patient_number'],
        doctorNumber: e['doctor_number'],
        diagnosis: e['diagnosis'],
        desc: e['desc'] ?? "",
        diagnosisDate: DateTime.parse(e['diagnosis_date']),
        doctorName: doctor['name'],
      );
    }).toList();
  }

  Future<List<Message>> fetchConversations() async {
    final patient = await SharedPreferenceService().getUser();
    if (patient == null) {
      throw Exception('User not found');
    }

    final response = await _supabase
        .from('messages')
        .select('*, user:sender_number(id_number, name)')
        .eq('receiver_number', patient.idNumber)
        .order('sent_at', ascending: false);

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response as List<dynamic>);

    final Map<String, Message> latestMessages = {};

    for (var messageMap in data) {
      final message = Message.fromMap(messageMap);
      final key = '${message.senderNumber}-${message.receiverNumber}';

      if (!latestMessages.containsKey(key) ||
          message.sentAt.isAfter(latestMessages[key]!.sentAt)) {
        latestMessages[key] = message;
      }
    }

    return latestMessages.values.toList();
  }

  Future<List<HeartMeasurement>> fetchMeasurements(String patientId) async {
    final response = await _supabase
        .from('heartratemeasurements')
        .select('*')
        .eq('patient_id', patientId)
        .order('recorded_at', ascending: false);

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response as List<dynamic>);

    return data.map((map) => HeartMeasurement.fromMap(map)).toList();
  }

  Future<PatientModel?> fetchUser() async {
    final user = await SharedPreferenceService().getUser();
    if (user == null) {
      throw Exception('User not found');
    }

    final response = await _supabase
        .from('patients')
        .select()
        .eq('patient_number', user.idNumber)
        .single();

    final Map<String, dynamic> data = response;
    return PatientModel.fromJson({
      'id_number': user.idNumber,
      'password_hash': user.passwordHash,
      'role': user.role,
      'name': user.name,
      'address': data['address'],
      'date_of_birth': data['date_of_birth'],
    });
  }
}
