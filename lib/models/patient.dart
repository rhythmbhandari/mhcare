class PatientModel {
  final String idNumber;
  final String passwordHash;
  final String role;
  final String name;
  final String? address;
  final String? dateOfBirth;

  PatientModel({
    required this.idNumber,
    required this.passwordHash,
    required this.role,
    required this.name,
    this.address,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'id_number': idNumber,
        'password_hash': passwordHash,
        'role': role,
        'name': name,
        'address': address,
        'date_of_birth': dateOfBirth,
      };

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      idNumber: json['id_number'] as String,
      passwordHash: json['password_hash'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      dateOfBirth: json['date_of_birth'],
    );
  }
}
