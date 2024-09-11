import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_call/resources/notification_services.dart';
import 'package:video_call/screens/main_screen.dart'; // Import main screen
import 'package:video_call/screens/sign_in_screen.dart'; // Import notification service
import 'constant/colors.dart'; // Import colors

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handling
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notifications
  NotificationService notificationService = NotificationService();
  notificationService.initialize(); // Initialize the notification service

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      home:
          const AuthCheck(), // Use AuthCheck widget to determine the home screen
    );
  }
}

// This widget checks whether the user is signed in or not
class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in, navigate to MainScreen
          return const MainScreen();
        } else {
          // User is not signed in, show SignInScreen
          return const SignInScreen();
        }
      },
    );
  }
}
