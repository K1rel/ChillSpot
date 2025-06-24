import 'package:domasna/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:domasna/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

Future<void> _handleForgotPassword() async {
  final email = _emailController.text.trim();
  if (email.isEmpty) return;

  setState(() => _isLoading = true);
  try {
    await AuthService.forgotPassword(email);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(email: email),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleForgotPassword,
              child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}