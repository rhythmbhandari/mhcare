class UserModel {
  final String idNumber;
  final String passwordHash;
  final String role;
  final String name;

  UserModel({
    required this.idNumber,
    required this.passwordHash,
    required this.role,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id_number': idNumber,
        'password_hash': passwordHash,
        'role': role,
        'name': name,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        idNumber: json['id_number'],
        passwordHash: json['password_hash'],
        role: json['role'],
        name: json['name'],
      );
}
