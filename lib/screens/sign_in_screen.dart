import 'package:flutter/material.dart';
import 'package:video_call/extension/sized_box_extension.dart';
import 'package:video_call/screens/personal_info_screen.dart';
import 'package:video_call/widgets/custom_app_bar.dart';
import '../constant/colors.dart';
import '../resources/auth_methods.dart';
import '../widgets/reused_elevated_button.dart';
import '../widgets/sign_in_info_text_form_field.dart';
import 'login_screen.dart'; // Import your custom widget

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String email = '';
  String password = '';
  String firstName = '';
  String secondName = '';
  String lastName = '';
  late AuthMethods _authMethods;

  @override
  void initState() {
    super.initState();
    _authMethods = AuthMethods();
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });

      bool success = await _authMethods.signUpWithEmailAndDetails(
        email,
        password,
        firstName,
        secondName,
        lastName,
      );
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PersonalInfoScreen(),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle signup failure
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Sign Up Screen",
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
                  const Text("Enter your details for sign up"),
                  30.kH,
                  CustomTextFormField(
                    labelText: 'First Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your first name' : null,
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                  20.kH,
                  CustomTextFormField(
                    labelText: 'Second Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your second name' : null,
                    onChanged: (value) {
                      setState(() {
                        secondName = value;
                      });
                    },
                  ),
                  20.kH,
                  CustomTextFormField(
                    labelText: 'Last Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your last name' : null,
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                  20.kH,
                  CustomTextFormField(
                    labelText: 'Email',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter an email' : null,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  20.kH,
                  CustomTextFormField(
                    labelText: 'Password',
                    validator: (value) => value!.length < 6
                        ? 'Enter a password 6+ chars long'
                        : null,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    isPasswordField:
                        true, // Set this to true to enable password visibility toggle
                  ),
                  20.kH,
                  isLoading
                      ? const CircularProgressIndicator()
                      : ReusedElevatedButton(
                          text: "Sign Up",
                          onPressed: signUp,
                          icon: Icons.email,
                        ),
                  20.kH,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: kTextButtonColor,
                          ),
                        ),
                      ),
                    ],
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
