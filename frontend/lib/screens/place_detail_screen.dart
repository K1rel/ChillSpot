import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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

  void _savePlace() {
    final placeDetails = {
      'name': _nameController.text,
      'altitude': double.tryParse(_altitudeController.text) ?? 0.0,
      'difficulty': _selectedDifficulty,
      'weather': _selectedWeather,
    };
    widget.onSave(placeDetails);
    Navigator.pop(context);
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
