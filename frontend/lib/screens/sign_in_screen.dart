import 'package:domasna/screens/profile_screen.dart';
import 'package:domasna/screens/sign_up_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
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
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Username:',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password:',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDDA15E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpScreen()),
                              );
                            },
                        ),
                      ],
                    ),
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
