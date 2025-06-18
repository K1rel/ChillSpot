import 'package:domasna/components/back_button.dart';
import 'package:domasna/components/profile_button.dart';
import 'package:domasna/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String? _currentProfilePic;
  File? _profileImage;
  bool _isLoading = false;
  bool _isProfilePicLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isProfilePicLoading = true;
    });
    
    try {
      final userData = await AuthService.getUserProfile();
      setState(() {
        _emailController.text = userData['email'] ?? '';
        _usernameController.text = userData['username'] ?? '';
        _currentProfilePic = userData['profile_pic'];
        _isProfilePicLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data: $e';
        _isProfilePicLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.updateProfile(
        email: _emailController.text,
        username: _usernameController.text,
        profileImage: _profileImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      
      // Return to previous screen after successful update
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      _buildTextField('Email:', Icons.email, _emailController),
                      const SizedBox(height: 16),
                      _buildTextField('Username:', Icons.person, _usernameController),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Text(
                            'Profile picture:',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildProfilePicture(),
                      const SizedBox(height: 24),
                      ProfileButton(
                        text: 'Confirm Edit',
                        onTap: _isLoading ? null : _updateProfile,
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: _getProfileImageWidget(),
            ),
          ),
          if (_isProfilePicLoading)
            const CircularProgressIndicator(),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.edit, size: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

 Widget _getProfileImageWidget() {
  if (_profileImage != null) {
    return Image.file(
      _profileImage!,
      fit: BoxFit.cover,
      width: 100,
      height: 100,
    );
  } else if (_currentProfilePic != null && _currentProfilePic!.isNotEmpty) {
    return Image.network(
      _currentProfilePic!, // Remove the base URL prefix
      fit: BoxFit.cover,
      width: 100,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultProfileImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  } else {
    return _buildDefaultProfileImage();
  }
}

  Widget _buildDefaultProfileImage() {
    return Center(
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }
}