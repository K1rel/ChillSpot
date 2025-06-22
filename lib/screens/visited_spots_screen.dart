// visited_spots_screen.dart
import 'package:domasna/screens/spot_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:domasna/services/visited_spot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'create_review_screen.dart'; // Add this import

class VisitedSpotsScreen extends StatefulWidget {
  @override
  _VisitedSpotsScreenState createState() => _VisitedSpotsScreenState();
}

class _VisitedSpotsScreenState extends State<VisitedSpotsScreen> {
  List<dynamic> _visitedSpots = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
     _loadCurrentUserId();
    _loadVisitedSpots();
    
  }
 Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }
  Future<void> _loadVisitedSpots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final visitedSpots = await VisitedSpotService.getVisitedSpots();
      setState(() {
        _visitedSpots = visitedSpots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load visited spots: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visited Spots'),
        backgroundColor: const Color(0xFF162927),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadVisitedSpots,
          ),
        ],
      ),
      backgroundColor: const Color(0xFF162927),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.white)))
              : _visitedSpots.isEmpty
                  ? Center(
                      child: Text(
                        'No visited spots yet',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _visitedSpots.length,
                      itemBuilder: (context, index) {
                        final visitedSpot = _visitedSpots[index];
                        final spot = visitedSpot['Spot'] ?? {};
                        final visitedAt = visitedSpot['VisitedAt'] != null
                            ? DateTime.parse(visitedSpot['VisitedAt'])
                            : null;
                        
                        // Determine if it's a friend's spot
                        final spotOwnerId = spot['UserID']?.toString();
                        final isFriendSpot = spotOwnerId != null && 
                                            _currentUserId != null && 
                                            spotOwnerId != _currentUserId;
                        
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: const Color(0xFF283D3A),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: Icon(Icons.check_circle, color: Colors.green, size: 36),
                            title: Text(
                              spot['Title'] ?? 'Untitled Spot',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpotDetailScreen(
                                    spotId: spot['ID'].toString(),
                                    isFriendSpot: isFriendSpot,
                                  ),
                                ),
                              );
                            },
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (visitedAt != null)
                                  Text(
                                    'Visited: ${DateFormat.yMMMd().add_jm().format(visitedAt)}',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                if (isFriendSpot)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "Friend's spot",
                                      style: TextStyle(
                                        color: Colors.blue[200],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                if (visitedSpot['Notes'] != null && visitedSpot['Notes'].isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '"${visitedSpot['Notes']}"',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateReviewScreen(
                                          spotId: spot['ID'].toString(),
                                          spotTitle: spot['Title'] ?? 'Untitled Spot',
                                        ),
                                      ),
                                    ).then((refresh) {
                                      if (refresh == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Review submitted successfully!')),
                                        );
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFDDA15E),
                                    foregroundColor: Colors.black,
                                    minimumSize: Size(0, 36),
                                  ),
                                  child: Text('Leave Review'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}