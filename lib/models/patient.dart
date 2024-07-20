import 'diagnosis.dart';
import 'message.dart';

class Patient {
  final String id;
  final String name;
  final String address;
  final DateTime dateOfBirth;
  final String password;
  final List<Diagnosis> diagnoses;
  final List<Message> messages;

  Patient({required this.id, required this.name, required this.address, required this.dateOfBirth, required this.password, this.diagnoses = const [], this.messages = const []});
}

