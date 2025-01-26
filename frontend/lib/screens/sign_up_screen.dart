import 'package:domasna/components/custom_rich_text.dart';
import 'package:domasna/components/elevated_button.dart';
import 'package:domasna/screens/profile_screen.dart';
import 'package:domasna/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

import '../components/profile_input_field.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/sunset.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFF283618).withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFBC6C25).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const InputField(label: 'Email:'),
                  const SizedBox(height: 15),
                  const InputField(label: 'Username:'),
                  const SizedBox(height: 15),
                  const InputField(label: 'Password:', obscureText: true),
                  const SizedBox(height: 15),
                  const InputField(
                      label: 'Confirm password:', obscureText: true),
                  const SizedBox(height: 70),
                  CustomElevatedButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomRichText(
                    text: 'Already have an account? ',
                    actionText: 'Log In',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
