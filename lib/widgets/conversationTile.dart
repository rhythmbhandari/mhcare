import 'dart:math' as e;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../utils/string_utils.dart';

// ConversationTile widget
class ConversationTile extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const ConversationTile({required this.message, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: RandomColorAvatar(
        initial: getFirstCharacter(message.name ?? "U"),
      ),
      title: Text(message.name ?? "Unknown"),
      subtitle: Text(
        message.message,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        DateFormat('MMM d, yyyy – h:mm a').format(message.sentAt.toLocal()),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }
}

class RandomColorAvatar extends StatelessWidget {
  final String initial;

  const RandomColorAvatar({required this.initial, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getRandomColor();

    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: Text(
        initial.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color getRandomColor() {
  final random = e.Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
