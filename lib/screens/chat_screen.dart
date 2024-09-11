import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_call/widgets/custom_app_bar.dart';

import '../resources/notification_services.dart'; // Import the notification service

class ChatScreen extends StatefulWidget {
  final String userId; // The ID of the user you're chatting with
  final String userName; // The name of the user you're chatting with

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref('App/Chats');
  String chatId = "";
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _notificationService.initialize(); // Initialize notification service
  }

  // Generate the chatId based on the current user's id and the other user's id
  void _initializeChat() {
    String currentUserId = _auth.currentUser!.uid;
    String otherUserId = widget.userId;

    // Simple logic to create a unique chat ID
    chatId = currentUserId.compareTo(otherUserId) < 0
        ? "$currentUserId\_$otherUserId"
        : "$otherUserId\_$currentUserId";
  }

  Future<void> _sendMessage(String message) async {
    String currentUserId = _auth.currentUser!.uid;
    String otherUserId = widget.userId;

    // Create a new message entry
    DatabaseReference newMessageRef = _chatRef.child(chatId).push();
    await newMessageRef.set({
      'senderId': currentUserId,
      'receiverId': otherUserId,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Clear the message input after sending
    _messageController.clear();

    // Send notification to the recipient
    await _notificationService.sendNotification(otherUserId, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: ('Chat with ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRef.child(chatId).orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(child: Text("No messages yet"));
                }

                // Handle the case when the snapshot data is not null
                Map<dynamic, dynamic>? messagesMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;

                if (messagesMap == null) {
                  return Center(child: Text("No messages yet"));
                }

                List<Map<String, dynamic>> messages = messagesMap.entries
                    .map((entry) => Map<String, dynamic>.from(entry.value))
                    .toList();

                return ListView.builder(
                  reverse: true, // Show the latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    bool isMe =
                        messageData['senderId'] == _auth.currentUser!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(messageData['message'] ?? ''),
                      ),
                    );
                  },
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
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
