import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/message.dart';
import '../../widgets/customtextfield.dart';

/// Chat screen for sending and receiving messages.
class ChatScreen extends StatefulWidget {
  final String patientNumber; // Receiver's unique identifier
  final String patientName;
  final String senderNumber; // Sender's unique identifier

  const ChatScreen({
    super.key,
    required this.patientNumber,
    required this.patientName,
    required this.senderNumber,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _loading = false;
  final myChannel = Supabase.instance.client
      .channel('my_channel'); // Supabase real-time channel

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch existing messages when the screen initializes
    _setupRealTimeSubscription(); // Set up real-time message subscription
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    myChannel.unsubscribe();
    super.dispose();
  }

  /// Fetches chat messages between sender and receiver from the database.
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

  /// Sends a new message to the receiver..
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _loading = true;
    });

    final newMessage = Message(
      id: const Uuid().v4(), // Generate a unique ID for the new message
      senderNumber: widget.senderNumber,
      receiverNumber: widget.patientNumber,
      message: message,
      sentAt: DateTime.now().toUtc(), // Current UTC time
    ).toMap();

    try {
      newMessage.remove('name'); // Remove unnecessary 'name' field if present
      await Supabase.instance.client.from('messages').insert(newMessage);

      _messageController.clear();
      _scrollToBottom(); // Scroll to the bottom of the chat list
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

  /// Scrolls the chat list to the bottom.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Sets up a real-time subscription to listen for new messages.
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
        title: Text('Chat: ${widget.patientName}'),
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('No messages'))
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
                    child: CustomTextFormField(
                      labelText: 'Type a message',
                      textController: _messageController,
                      onChanged: (_) {},
                      readOnly: false,
                      textInputType: TextInputType.name,
                      inputFormatters: const [],
                      color: Colors.white54,
                      obscureText: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _loading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send,
                              color: Color.fromRGBO(220, 53, 69, 1)),
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
