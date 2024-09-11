import 'package:flutter/material.dart';
import '../resources/auth_methods.dart';
import 'main_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String secondName = '';
  String lastName = '';
  bool isLoading = false;
  final AuthMethods _authMethods = AuthMethods();

  Future<void> saveDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      // Access the Firebase Auth instance from the AuthMethods class
      String userId = _authMethods.auth.currentUser!.uid;

      // Call the method to save user details
      await _authMethods.saveUserDetails(
          userId, firstName, secondName, lastName);

      // Navigate to the main screen after saving details
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Personal Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter first name' : null,
                onChanged: (value) => firstName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Second Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter second name' : null,
                onChanged: (value) => secondName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter last name' : null,
                onChanged: (value) => lastName = value,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: saveDetails,
                      child: const Text("Submit"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
