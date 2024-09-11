import 'package:flutter/material.dart';
import 'package:video_call/constant/colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool
      isPasswordField; // Added this parameter to specify if it's a password field

  const CustomTextFormField({
    Key? key,
    required this.labelText,
    required this.onChanged,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.isPasswordField =
        false, // Default is false, meaning it's not a password field
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true; // This controls the visibility of the password

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : (Icons.visibility),
                  color: kPrimaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Toggle password visibility
                  });
                },
              )
            : null,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPasswordField
          ? _obscureText
          : false, // Hide the text for password fields
    );
  }
}
