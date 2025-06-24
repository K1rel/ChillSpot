

import 'package:domasna/components/custom_rich_text.dart';
import 'package:domasna/components/elevated_button.dart';
import 'package:domasna/screens/forgot_password_screen.dart';
import 'package:domasna/screens/profile_screen.dart';
import 'package:domasna/screens/sign_up_screen.dart';
import 'package:domasna/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/profile_input_field.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 Future<void> _handleLogin() async {
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  try {
    // AuthService.login now returns a Map directly, not an http.Response
    final responseData = await AuthService.login(username, password);
    
    // No need to decode again - responseData is already a Map
    final userId = responseData['user_id'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
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
                  InputField(label: 'Username:', controller: _usernameController),
                  const SizedBox(height: 15),
                  InputField(label: 'Password:', controller: _passwordController, obscureText: true),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
  },
  child: Text(
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
                  CustomElevatedButton(
                    text: 'Log In',
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 10),
                  CustomRichText(
                    text: "Don't have an account? ",
                    actionText: 'Sign Up',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
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
