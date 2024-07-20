import 'dart:convert';

class HeartMeasurement {
  HeartMeasurement({
    required this.id,
    required this.patientId,
    required this.averageBpm,
    required this.maxBpm,
    required this.minBpm,
    required this.recordedAt,
  });

  String id;
  String patientId;
  double averageBpm;
  double maxBpm;
  double minBpm;
  DateTime recordedAt;

  factory HeartMeasurement.fromMap(Map<String, dynamic> json) =>
      HeartMeasurement(
        id: json["id"],
        patientId: json["patient_id"],
        averageBpm: json["average_bpm"].toDouble(),
        maxBpm: json["max_bpm"].toDouble(),
        minBpm: json["min_bpm"].toDouble(),
        recordedAt: DateTime.parse(json["recorded_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "patient_id": patientId,
        "average_bpm": averageBpm,
        "max_bpm": maxBpm,
        "min_bpm": minBpm,
        "recorded_at": recordedAt.toIso8601String(),
      };
}
