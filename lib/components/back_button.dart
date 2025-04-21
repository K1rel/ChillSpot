import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CustomBackButton({
    Key? key,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap ?? () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back, color: iconColor ?? Colors.brown[300]),
      label: const Text(
        'Go Back',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
