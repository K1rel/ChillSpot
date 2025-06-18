import 'package:flutter/material.dart';
import 'package:domasna/services/visited_spot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VisitedSpotsScreen extends StatefulWidget {
  @override
  _VisitedSpotsScreenState createState() => _VisitedSpotsScreenState();
}

class _VisitedSpotsScreenState extends State<VisitedSpotsScreen> {
  List<dynamic> _visitedSpots = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVisitedSpots();
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (visitedAt != null)
                                  Text(
                                    'Visited: ${DateFormat.yMMMd().add_jm().format(visitedAt)}',
                                    style: TextStyle(color: Colors.white70),
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
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right, color: Colors.white),
                            onTap: () {
                              // Implement visited spot detail view if needed
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}