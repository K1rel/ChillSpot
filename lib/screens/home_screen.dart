import 'package:domasna/components/elevated_button.dart';
import 'package:domasna/components/home_button.dart';
import 'package:flutter/material.dart';
import 'package:domasna/screens/sign_in_screen.dart';
import 'package:domasna/screens/sign_up_screen.dart';

class ChillSpotHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/home.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFF283618).withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC6C25).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome to\nChillSpot!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFEFAE0),
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomElevatedButton(
                        text: 'Sign Up',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        backgroundColor: const Color(0xFFDDA15E),
                        foregroundColor: const Color(0xFFFEFAE0),
                        fontSize: 18,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 40),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      const SizedBox(height: 40),
                      CustomElevatedButton(
                        text: 'Sign In',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()),
                          );
                        },
                        backgroundColor: const Color(0xFFDDA15E),
                        foregroundColor: const Color(0xFFFEFAE0),
                        fontSize: 18,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 40),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
