class Diagnosis {
  final String id;
  final String patientNumber;
  final String doctorNumber;
  final String diagnosis;
  final String? desc;
  final DateTime diagnosisDate;
  final String doctorName;

  Diagnosis({
    required this.desc,
    required this.id,
    required this.patientNumber,
    required this.doctorNumber,
    required this.diagnosis,
    required this.diagnosisDate,
    required this.doctorName,
  });

  factory Diagnosis.fromMap(Map<String, dynamic> map) {
    return Diagnosis(
      id: map['id'],
      desc: map['desc'],
      patientNumber: map['patient_number'],
      doctorNumber: map['doctor_number'],
      diagnosis: map['diagnosis'],
      diagnosisDate: DateTime.parse(map['diagnosis_date']),
      doctorName: map['doctor_name'],
    );
  }
}
