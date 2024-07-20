import 'package:david/services/patientService.dart';
import 'package:flutter/material.dart';
import '../../services/databaseService.dart';
import '../../models/message.dart';
import '../../widgets/conversationTile.dart';
import '../staff/sendMessageScreen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  late Future<List<Message>> _conversationsFuture;
  final PatientService _messagesService = PatientService();

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _messagesService.fetchConversations();
  }

  Future<void> _refreshConversations() async {
    setState(() {
      _conversationsFuture = _messagesService.fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConversations,
        child: FutureBuilder<List<Message>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching conversations. ${snapshot.error}',
                  style: TextStyle(color: Colors.red[700]),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No conversations available.'));
            } else {
              final conversations = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: conversations.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 32, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ConversationTile(
                    message: conversation,
                    onTap: () async {
                      final senderNumber =
                          await SharedPreferenceService().getUser();
                      if (senderNumber != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              patientNumber: conversation.senderNumber,
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
      ),
    );
  }
}
