import 'dart:developer';
import 'dart:math';

import 'package:david/screens/staff/sendMessageScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/message.dart';
import '../../services/databaseService.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user.dart';
import '../../services/databaseService.dart';
import '../../utils/string_utils.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<Message>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _fetchConversations();
  }

  Future<List<Message>> _fetchConversations() async {
    final patient = await SharedPreferenceService().getUser();
    if (patient == null) {
      throw Exception('User not found');
    }
    final response = await Supabase.instance.client
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Message>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching conversations. ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No conversations available.'));
          } else {
            final conversations = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: conversations.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 32, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ListTile(
                  leading: RandomColorAvatar(
                    initial: getFirstCharacter(conversation.name ?? "U"),
                  ),
                  title: Text(conversation.name ?? "Unknown"),
                  subtitle: Text(
                    conversation.message,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DateFormat('MMM d, yyyy – h:mm a')
                        .format(conversation.sentAt.toLocal()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () async {
                    final senderNumber =
                        await SharedPreferenceService().getUser();
                    if (senderNumber != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            patientNumber: conversation.receiverNumber,
                            patientName: conversation.name ?? "Unknown",
                            senderNumber: senderNumber.idNumber,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

Color getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

class RandomColorAvatar extends StatelessWidget {
  final String initial;

  const RandomColorAvatar({required this.initial, super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getRandomColor(); // Generate a random color

    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
