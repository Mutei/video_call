import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart'; // Import WebRTC
import 'package:permission_handler/permission_handler.dart';
import '../resources/fetch_from_database.dart';
import '../resources/notification_services.dart'; // Import the notification service

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

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
  final UserDataService _userDataService =
      UserDataService(); // Initialize UserDataService

  late RTCPeerConnection _peerConnection;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool isCaller = false; // New flag to indicate if the user is the caller

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _notificationService.initialize(); // Initialize notification service
    _initializeRenderers();
    _listenForIncomingCalls(); // Listen for incoming calls
  }

  void _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Generate the chatId based on the current user's id and the other user's id
  void _initializeChat() {
    String currentUserId = _auth.currentUser!.uid;
    String otherUserId = widget.userId;

    chatId = currentUserId.compareTo(otherUserId) < 0
        ? "$currentUserId\_$otherUserId"
        : "$otherUserId\_$currentUserId";
  }

  // Listen for incoming calls (Only for the receiver)
  void _listenForIncomingCalls() {
    String currentUserId = _auth.currentUser!.uid;

    // Only listen for incoming calls if the current user is the receiver
    _chatRef.child(chatId).child('call').onValue.listen((event) async {
      if (event.snapshot.exists) {
        var callData = event.snapshot.value as Map;
        String callerId = callData['callerId'];

        // Check if the current user is the receiver (not the one who made the call)
        if (callerId != currentUserId) {
          // Fetch caller name using the UserDataService
          String callerName = await _userDataService.getUserFullName(callerId);

          // Show incoming call dialog
          showDialog(
            context: context,
            builder: (context) => _buildIncomingCallUI(callerName),
          );
        }
      }
    });
  }

  // Method to check for camera and microphone permissions
  Future<void> _checkPermissions() async {
    if (await Permission.camera.isPermanentlyDenied ||
        await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    } else if (await Permission.camera.isDenied ||
        await Permission.microphone.isDenied) {
      await [Permission.camera, Permission.microphone].request();
    }
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

  // Initialize WebRTC for video calls
  Future<void> _startVideoCall() async {
    // Check for permissions before starting the call
    await _checkPermissions();

    try {
      if (await Permission.camera.isGranted &&
          await Permission.microphone.isGranted) {
        Map<String, dynamic> configuration = {
          'iceServers': [
            {'urls': 'stun:stun.l.google.com:19302'}
          ]
        };

        _peerConnection = await createPeerConnection(configuration);

        _localStream = await navigator.mediaDevices
            .getUserMedia({'video': true, 'audio': true});
        _localStream!.getTracks().forEach((track) {
          _peerConnection.addTrack(track, _localStream!);
        });

        _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
          // Handle the candidate
        };

        _peerConnection.onTrack = (RTCTrackEvent event) {
          if (event.track.kind == 'video') {
            _remoteRenderer.srcObject = event.streams[0];
          }
        };

        setState(() {
          _localRenderer.srcObject = _localStream;
        });

        // Set the user as the caller
        isCaller = true;

        // Send a call notification to the receiver via Firebase
        await _sendCallNotification();
      } else {
        print("Camera or microphone permission not granted");
      }
    } catch (error) {
      print("Error initializing video call: $error");
    }
  }

  // Method to notify the receiver of the video call (called by the sender only)
  Future<void> _sendCallNotification() async {
    String currentUserId = _auth.currentUser!.uid;
    String otherUserId = widget.userId;

    DatabaseReference callNotificationRef =
        _chatRef.child(chatId).child('call');
    await callNotificationRef.set({
      'callerId': currentUserId,
      'callerName': _auth.currentUser!.displayName ?? 'Unknown',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Send a push notification to the receiver via FCM
    await _notificationService.sendNotification(otherUserId,
        "Incoming video call from ${_auth.currentUser!.displayName ?? 'Unknown'}");
  }

  // Incoming call UI
  Widget _buildIncomingCallUI(String callerName) {
    return AlertDialog(
      title: Text("Incoming Video Call"),
      content: Text("$callerName is calling you..."),
      actions: [
        TextButton(
          onPressed: () {
            _acceptVideoCall();
          },
          child: Text("Accept"),
        ),
        TextButton(
          onPressed: () {
            _declineVideoCall();
          },
          child: Text("Decline"),
        ),
      ],
    );
  }

  // Accept video call logic
  void _acceptVideoCall() {
    Navigator.pop(context); // Close the dialog
    _startVideoCall(); // Start the video call on the receiver's side
  }

  // Decline video call logic
  void _declineVideoCall() {
    // Remove the call notification from the database
    _chatRef.child(chatId).child('call').remove();

    // Close the dialog
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.userName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall, // Video call button
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 10,
                  width: 100,
                  height: 150,
                  child: RTCVideoView(_localRenderer), // Local video stream
                ),
                RTCVideoView(_remoteRenderer), // Remote video stream
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _chatRef.child(chatId).orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(child: Text("No messages yet"));
                }

                Map<dynamic, dynamic>? messagesMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;

                if (messagesMap == null) {
                  return Center(child: Text("No messages yet"));
                }

                List<Map<String, dynamic>> messages = messagesMap.entries
                    .map((entry) => Map<String, dynamic>.from(entry.value))
                    .toList();

                return ListView.builder(
                  reverse: true,
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
