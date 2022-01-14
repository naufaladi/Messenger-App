import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final double height;
  final double width;
  final Function onPressed;

  const RoundedButton({
    required this.title,
    required this.height,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue[400],
      ),
      child: TextButton(
        onPressed: () => onPressed(),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
