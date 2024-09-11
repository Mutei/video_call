// import 'package:flutter/material.dart';
// import '../resources/auth_methods.dart';
// import 'personal_info_screen.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String verificationId;
//   const OtpScreen({required this.verificationId, super.key});
//
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   final _otpController = TextEditingController();
//   bool isLoading = false;
//   final AuthMethods _authMethods = AuthMethods();
//
//   Future<void> verifyOtp() async {
//     setState(() {
//       isLoading = true;
//     });
//     bool isVerified = await _authMethods.signInWithOtp(
//         widget.verificationId, _otpController.text);
//
//     if (isVerified) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => PersonalInfoScreen(),
//         ),
//       );
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid OTP')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Enter OTP")),
//       body: Center(
//         child: isLoading
//             ? const CircularProgressIndicator()
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextField(
//                     controller: _otpController,
//                     decoration: const InputDecoration(
//                       labelText: "OTP",
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: verifyOtp,
//                     child: const Text("Verify"),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
