class Message {
  final String? id;
  final String senderNumber;
  final String receiverNumber;
  final String message;
  final String? name;
  final DateTime sentAt;

  Message({
    this.id,
    this.name,
    required this.senderNumber,
    required this.receiverNumber,
    required this.message,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sender_number': senderNumber,
      'receiver_number': receiverNumber,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      name: map['user'] != null ? map['user']['name'] : null,
      senderNumber: map['sender_number'],
      receiverNumber: map['receiver_number'],
      message: map['message'],
      sentAt: DateTime.parse(map['sent_at']),
    );
  }
}
