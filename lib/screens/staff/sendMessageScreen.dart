import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/message.dart';
import '../../services/databaseService.dart';

class ChatScreen extends StatefulWidget {
  final String patientNumber;
  final String patientName;
  final String senderNumber;

  ChatScreen({
    required this.patientNumber,
    required this.patientName,
    required this.senderNumber,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _loading = false;
  final myChannel = Supabase.instance.client.channel('my_channel');

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _setupRealTimeSubscription();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    myChannel.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .or('and(sender_number.eq.${widget.senderNumber},receiver_number.eq.${widget.patientNumber}),and(sender_number.eq.${widget.patientNumber},receiver_number.eq.${widget.senderNumber})')
        .order('sent_at', ascending: true);

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);
    setState(() {
      _messages = data.map((e) => Message.fromMap(e)).toList();
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _loading = true;
    });

    final newMessage = Message(
      id: Uuid().v4(),
      senderNumber: widget.senderNumber,
      receiverNumber: widget.patientNumber,
      message: message,
      sentAt: DateTime.now().toUtc(),
    ).toMap();

    try {
      newMessage.remove('name');
      await Supabase.instance.client.from('messages').insert(newMessage);

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error sending message: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _setupRealTimeSubscription() {
    myChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.insert) {
              final newMessage = Message.fromMap(payload.newRecord);

              setState(() {
                _messages.add(newMessage);
              });

              _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.patientName}'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(child: Text('No messages'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isSender =
                            msg.senderNumber == widget.senderNumber;
                        return ListTile(
                          title: Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Colors.teal
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg.message,
                                style: TextStyle(
                                  color: isSender ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  _loading
                      ? CircularProgressIndicator()
                      : IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
