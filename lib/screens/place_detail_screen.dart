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
      _altitudeController.text =
          widget.existingDetails!['altitude']?.toString() ?? '';
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDayImage ? Icons.wb_sunny : Icons.nightlight_round,
                  color: isDayImage ? Colors.orange : Colors.indigo,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "$label Image",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(isDayImage, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _pickImage(isDayImage, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.green[200]!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (image != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.grey[400], size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF606C38), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: keyboardType == TextInputType.number
              ? (value) {
                  setState(() {
                    controller.text = value.replaceAll(RegExp(r'[^0-9.]'), '');
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      Function(String?) onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF606C38), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Place Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF606C38),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with location info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${widget.location.latitude.toStringAsFixed(6)}\nLng: ${widget.location.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Basic Info Section
            _buildTextField("Name", _nameController, hint: "Enter place name"),
            const SizedBox(height: 16),

            _buildTextField("Altitude (meters)", _altitudeController,
                keyboardType: TextInputType.number, hint: "Enter altitude"),
            const SizedBox(height: 20),

            // Images Section
            const Text(
              "Images",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildImageSelector("Day", true, _dayImage),
            const SizedBox(height: 16),
            _buildImageSelector("Night", false, _nightImage),
            const SizedBox(height: 20),

            // Settings Section
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
                "Difficulty",
                _selectedDifficulty,
                _difficultyOptions,
                (value) => setState(() => _selectedDifficulty = value!),
                Icons.trending_up),
            const SizedBox(height: 16),

            _buildDropdown(
                "Weather Accessibility",
                _selectedWeather,
                _weatherOptions,
                (value) => setState(() => _selectedWeather = value!),
                Icons.wb_cloudy),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _savePlace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283618),
                  foregroundColor:
                      Colors.white, // Fixed: explicit white text color
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 24),
                    SizedBox(width: 12),
                    Text(
                      "Save Place",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
