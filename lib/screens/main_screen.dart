import 'package:flutter/material.dart';
import 'package:video_call/widgets/custom_app_bar.dart';
import 'package:video_call/widgets/custom_drawer.dart'; // Import the user data service
import 'package:firebase_auth/firebase_auth.dart';

import '../resources/fetch_from_database.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String userFullName = "Main Screen";
  String userFirstName = "Welcome"; // Default title
  final UserDataService _userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    _loadUserFullName();
    _loadUserFirstName();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: userFirstName, // Display the user's full name in the app bar
      ),
      drawer: const CustomDrawer(),
    );
  }
}
