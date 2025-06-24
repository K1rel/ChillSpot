import 'package:domasna/components/custom_rich_text.dart';
import 'package:domasna/components/elevated_button.dart';
import 'package:domasna/screens/profile_screen.dart';
import 'package:domasna/screens/sign_in_screen.dart';
import 'package:domasna/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../components/profile_input_field.dart';


class SignUpScreen extends StatefulWidget{

  @override 
  _SignUpScreenState createState() => _SignUpScreenState();

}

class _SignUpScreenState extends State<SignUpScreen> {
   final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

    @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


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
                   InputField(label: 'Email:', controller: _emailController),
                  const SizedBox(height: 15),
                   InputField(label: 'Username:', controller: _usernameController),
                  const SizedBox(height: 15),
                   InputField(label: 'Password:',controller: _passwordController , obscureText: true),
                  const SizedBox(height: 15),
                   InputField(
                      label: 'Confirm password:', controller: _confirmPasswordController , obscureText: true),
                  const SizedBox(height: 70),
                  CustomElevatedButton(
                    text: 'Sign Up',
                    onPressed: () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ProfileScreen()),
                      
                     final email = _emailController.text.trim();
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();
                      final confirmPassword = _confirmPasswordController.text.trim();

                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Passwords do not match")),
                        );
                        return;
                      }

                   try {
  final response = await AuthService.register(email, username, password);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => ProfileScreen()),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Registration failed: $e')),
  );
}
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
