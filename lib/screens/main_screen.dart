import 'package:flutter/material.dart';
import 'package:video_call/widgets/custom_app_bar.dart';
import 'package:video_call/widgets/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../resources/fetch_from_database.dart';
import '../widgets/user_list_widget.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String userFullName = "Main Screen";
  String userFirstName = "Welcome"; // Default title
  final UserDataService _userDataService = UserDataService();
  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUserFullName();
    _loadUserFirstName();
    _loadAllUsers();
  }

  Future<void> _loadUserFullName() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String fullName = await _userDataService.getUserFullName(userId);
    setState(() {
      userFullName = "Welcome $fullName";
    });
  }

  Future<void> _loadUserFirstName() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String fullName = await _userDataService.getUserFirstName(userId);
    setState(() {
      userFirstName = "Welcome $fullName";
    });
  }

  Future<void> _loadAllUsers() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, String>> allUsers = await _userDataService.getAllUsers();

    // Filter out the current logged-in user from the list
    setState(() {
      users =
          allUsers.where((user) => user['userId'] != currentUserId).toList();
    });
  }

  void _handleUserPressed(String userId, String fullName) {
    // Navigate to the chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(userId: userId, userName: fullName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: userFirstName, // Display the user's full name in the app bar
      ),
      drawer: const CustomDrawer(),
      body: UserListWidget(
        users: users,
        onUserPressed: (userId) {
          // Find the user by userId to pass the fullName to the ChatScreen
          String fullName = users
                  .firstWhere((user) => user['userId'] == userId)['fullName'] ??
              'Unknown User';
          _handleUserPressed(userId, fullName);
        },
      ),
    );
  }
}
