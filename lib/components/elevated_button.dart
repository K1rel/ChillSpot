import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  const CustomElevatedButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFDDA15E),
    this.foregroundColor = Colors.white,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: foregroundColor, fontSize: fontSize),
      ),
    );
  }
}
