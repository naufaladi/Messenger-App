import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String placeholder;
  final String regEx;
  final bool obscureText;

  CustomTextFormField({
    required this.onSaved,
    required this.placeholder,
    required this.regEx,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    // String validatorText (placeholder) {
    //   if (placeholder == "Password") {
    //     return 'Invalid Password'
    //   } else
    //   ;
    // }

    return TextFormField(
      onSaved: (_value) => onSaved(_value!),
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black),
      obscureText: obscureText,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.bottom,
      validator: (value) => placeholder == 'Password'
          ? RegExp(regEx).hasMatch(value!)
              ? null
              : 'Please enter a valid password (min. 8 characters).'
          : RegExp(regEx).hasMatch(value!)
              ? null
              : 'Invalid value',
      decoration: InputDecoration(
        fillColor: Colors.grey[50],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.black45),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Function(String) onEditingComplete;
  final String placeholder;
  final bool obscuretext;
  final TextEditingController controller;
  IconData? icon;

  CustomTextField({
    required this.onEditingComplete,
    required this.placeholder,
    required this.obscuretext,
    required this.controller,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onEditingComplete: () => onEditingComplete(controller.value.text),
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black),
      obscureText: obscuretext,
      decoration: InputDecoration(
        fillColor: Colors.black12,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: placeholder,
        hintStyle: TextStyle(
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
