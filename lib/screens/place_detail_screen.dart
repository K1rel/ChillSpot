import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:domasna/services/spot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];
  final List<String> _weatherOptions = [
    'Sunny only',
    'Accessible in rain',
    'Accessible on dirt roads'
  ];

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

 void _savePlace() async {

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

   if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  final placeDetails = {
    'name': _nameController.text,
    'altitude': double.tryParse(_altitudeController.text) ?? 0.0,
    'difficulty': _selectedDifficulty,
    'weather': _selectedWeather,
  };

  try {
    // Save to backend
    await SpotService.saveSpotToServer(
      lat: widget.location.latitude,
      lng: widget.location.longitude,
      title: _nameController.text,
      desc: "Added from app", // You can improve UI for this later
      weather: _selectedWeather,
      userId: userId, // Replace with actual user ID from state/auth
    );

    // Trigger any local save/callback logic
    widget.onSave(placeDetails);

    // Go back
    Navigator.pop(context);
  } catch (e) {
    // Optionally show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save place: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Place Details"), backgroundColor: Color(0xFF606C38)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _nameController),

            SizedBox(height: 12),
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

            SizedBox(height: 12),
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

            SizedBox(height: 12),
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

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePlace,
              child: Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF283618)),
            ),
          ],
        ),
      ),
    );
  }
}
