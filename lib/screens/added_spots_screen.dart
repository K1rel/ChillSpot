import 'package:domasna/screens/spot_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:domasna/services/spot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddedSpotsScreen extends StatefulWidget {
  @override
  _AddedSpotsScreenState createState() => _AddedSpotsScreenState();
}

class _AddedSpotsScreenState extends State<AddedSpotsScreen> {
  List<dynamic> _spots = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spots = await SpotService.getSpotsByUserId();
      setState(() {
        _spots = spots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load spots: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Added Spots'),
        backgroundColor: const Color(0xFF162927),
      ),
      backgroundColor: const Color(0xFF162927),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.white)))
              : _spots.isEmpty
                  ? Center(
                      child: Text(
                        'No spots added yet',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _spots.length,
                      itemBuilder: (context, index) {
                        final spot = _spots[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: const Color(0xFF283D3A),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: Icon(Icons.location_on, color: Color(0xFFDDA15E), size: 36),
                            title: Text(
                              spot['Title'] ?? 'Untitled Spot',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  '${spot['Latitude']?.toStringAsFixed(6)}, ${spot['Longitude']?.toStringAsFixed(6)}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  spot['Description'] ?? 'No description',
                                  style: TextStyle(color: Colors.white70),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right, color: Colors.white),
                            onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpotDetailScreen(spotId: spot['ID'].toString()),
                                    ),
                                  );
                                },
                          ),
                        );
                      },
                    ),
    );
  }
}