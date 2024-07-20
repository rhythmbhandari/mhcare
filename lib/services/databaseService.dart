import '../models/diagnosis.dart';
import '../models/message.dart';
import '../models/patient.dart';

class DatabaseService {
  Future<List<Patient>?> getPatients() async {
    // Fetch patients from the database

  }

  Future<void> addPatient(Patient patient) async {
    // Add patient to the database
  }

  Future<void> updatePatient(Patient patient) async {
    // Update patient details in the database
  }

  Future<void> addDiagnosis(Diagnosis diagnosis) async {
    // Add diagnosis to the database
  }

  Future<List<Message>?> getMessages(String userId, String receiverId) async {
    // Fetch messages from the database
  }

  Future<void> sendMessage(Message message) async {
    // Send message to the database
  }
}
