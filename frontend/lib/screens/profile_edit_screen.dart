import 'package:domasna/components/back_button.dart';
import 'package:domasna/components/profile_button.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.brown[600],
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Email:', Icons.email),
                      const SizedBox(height: 16),
                      _buildTextField('Username:', Icons.person),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Text(
                            'Profile picture:',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage('images/profile.jpg')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ProfileButton(
                        text: 'Confirm Edit',
                        onTap: () {},
                        height: 48,
                        borderRadius: 8,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ProfileButton(
                        text: 'Change Password',
                        onTap: () {},
                        height: 48,
                        borderRadius: 8,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomBackButton(
                onTap: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
