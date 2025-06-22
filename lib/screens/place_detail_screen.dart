import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:domasna/services/spot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PlaceDetailScreen extends StatefulWidget {
  final LatLng location;
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? existingDetails;

  const PlaceDetailScreen({
    required this.location,
    required this.onSave,
    this.existingDetails,
    Key? key,
  }) : super(key: key);

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();
  String _selectedDifficulty = 'Easy';
  String _selectedWeather = 'Sunny only';
  File? _dayImage;
  File? _nightImage;

  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];
  final List<String> _weatherOptions = [
    'Sunny only',
    'Accessible in rain',
    'Accessible on dirt roads'
  ];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingDetails != null) {
      _nameController.text = widget.existingDetails!['name'] ?? '';
      _altitudeController.text = widget.existingDetails!['altitude']?.toString() ?? '';
      _selectedDifficulty = widget.existingDetails!['difficulty'] ?? 'Easy';
      _selectedWeather = widget.existingDetails!['weather'] ?? 'Sunny only';
    }
  }

  Future<void> _pickImage(bool isDayImage, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isDayImage) {
            _dayImage = File(image.path);
          } else {
            _nightImage = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _savePlace() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save spots')),
      );
      return;
    }

    try {
      await SpotService.saveSpotToServer(
        lat: widget.location.latitude,
        lng: widget.location.longitude,
        title: _nameController.text,
        desc: "Added from app",
        weather: _selectedWeather,
        altitude: double.tryParse(_altitudeController.text) ?? 0.0,
        dayImage: _dayImage,
        nightImage: _nightImage,
      );

      widget.onSave({
        'name': _nameController.text,
        'altitude': double.tryParse(_altitudeController.text) ?? 0.0,
        'difficulty': _selectedDifficulty,
        'weather': _selectedWeather,
        'dayImage': _dayImage?.path,
        'nightImage': _nightImage?.path,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save place: $e')),
      );
    }
  }

  Widget _buildImageSelector(String label, bool isDayImage, File? image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label Image:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(isDayImage, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[100],
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(isDayImage, ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[100],
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (image != null)
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Place Details"), backgroundColor: Color(0xFF606C38)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: _nameController),
              const SizedBox(height: 12),
              
              Text("Altitude (meters):", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _altitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Enter altitude"),
                onChanged: (value) {
                  setState(() {
                    _altitudeController.text = value.replaceAll(RegExp(r'[^0-9.]'), '');
                    _altitudeController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _altitudeController.text.length),
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              
              // Day image selector
              _buildImageSelector("Day", true, _dayImage),
              
              // Night image selector
              _buildImageSelector("Night", false, _nightImage),
              
              Text("Difficulty:", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
                items: _difficultyOptions.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              
              Text("Weather Accessibility:", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedWeather,
                onChanged: (value) {
                  setState(() {
                    _selectedWeather = value!;
                  });
                },
                items: _weatherOptions.map((weather) {
                  return DropdownMenuItem(
                    value: weather,
                    child: Text(weather),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _savePlace,
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF283618),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}