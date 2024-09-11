import 'package:flutter/material.dart';
import 'package:video_call/extension/sized_box_extension.dart';
import '../constant/colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/reused_elevated_button.dart';
import '../resources/auth_methods.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String email = '';
  String password = '';
  late AuthMethods _authMethods;

  @override
  void initState() {
    super.initState();
    _authMethods = AuthMethods();
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });

      bool success = await _authMethods.signInWithEmail(email, password);
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle login failure
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Login Screen",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Enter your email and password for login"),
                  30.kH,
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter an email' : null,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  20.kH,
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Enter a password 6+ chars long'
                        : null,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  20.kH,
                  isLoading
                      ? const CircularProgressIndicator()
                      : ReusedElevatedButton(
                          text: "Login",
                          onPressed: login,
                          icon: Icons.login,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
