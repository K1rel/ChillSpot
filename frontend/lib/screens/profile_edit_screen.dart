import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                margin: EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField('Email:', Icons.email),
                      SizedBox(height: 16),
                      _buildTextField('Username:', Icons.person),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Profile picture:',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: const AssetImage('images/profile.jpg')
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                            'Confirm Edit',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                            ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                            'Change Password',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.brown[300]),
                label: Text(
                  'Go Back',
                  style: TextStyle(
                      color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
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
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
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