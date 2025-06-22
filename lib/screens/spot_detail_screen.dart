import 'package:flutter/material.dart';
import 'package:domasna/services/spot_service.dart';
import 'package:domasna/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class SpotDetailScreen extends StatefulWidget {
  final String spotId;
  
  const SpotDetailScreen({Key? key, required this.spotId, required bool isFriendSpot}) : super(key: key);

  @override
  _SpotDetailScreenState createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  
  Map<String, dynamic>? _spot;
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String? _error;
  bool _isLiking = false;
  bool _isLiked = false;
  bool _isReviewing = false;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpotDetails();
     _checkIfLiked();
     _trackVisit();
  }


  Future<void> _trackVisit() async {
  try {
    await SpotService.trackVisit(widget.spotId);
    // Update UI immediately
    setState(() {
      if (_spot != null) {
        _spot = {
          ..._spot!,
          'VisitCount': (_spot!['VisitCount'] ?? 0) + 1,
        };
      }
    });
  } catch (e) {
    print('Failed to track visit: $e');
  }
}
   Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final likedSpots = prefs.getStringList('liked_spots') ?? [];
    setState(() {
      _isLiked = likedSpots.contains(widget.spotId);
    });
  }

 Future<void> _loadSpotDetails() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final spot = await SpotService.getSpotById(widget.spotId);
    final reviews = await ReviewService.getReviewsForSpot(widget.spotId);
    
    // Debug prints
    print('Loaded spot data: $spot');
    print('Day image URL: ${spot['DayImageUrl']}');
    print('Night image URL: ${spot['NightImageUrl']}');
    
    setState(() {
      _spot = spot;
      _reviews = reviews;
      _isLoading = false;
    });
  } catch (e) {
    print('Error loading spot details: $e');
    setState(() {
      _error = 'Failed to load spot: $e';
      _isLoading = false;
    });
  }
}

 Future<void> _likeSpot() async {
  if (_isLiked) return;
  
  setState(() {
    _isLiking = true;
  });

  try {
    await SpotService.likeSpot(widget.spotId);
    
    // Update local storage
    final prefs = await SharedPreferences.getInstance();
    final likedSpots = prefs.getStringList('liked_spots') ?? [];
    likedSpots.add(widget.spotId);
    await prefs.setStringList('liked_spots', likedSpots);

    // Update UI
    setState(() {
      _isLiked = true;
      if (_spot != null) {
        _spot = {
          ..._spot!,
          'FavoritesCount': (_spot!['FavoritesCount'] ?? 0) + 1,
        };
      }
    });
    
    // Optional: Refresh full data
    await _loadSpotDetails();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to like spot: $e')),
    );
  } finally {
    setState(() {
      _isLiking = false;
    });
  }
}

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) return;
    
    setState(() {
      _isReviewing = true;
    });

    try {
      await ReviewService.createReview(
        spotId: widget.spotId,
        text: _reviewController.text,
      );
      _reviewController.clear();
      await _loadSpotDetails(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      setState(() {
        _isReviewing = false;
      });
    }
  }
  Widget _buildImageGallery() {
  List<Widget> images = [];

  if (_spot?['DayImageUrl'] != null) {
    images.add(
      CachedNetworkImage(
        imageUrl: _spot!['DayImageUrl'],
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) {
          print('Error loading day image: $error');
          return Container(
            color: Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white),
                  Text('Day Image Error', style: TextStyle(color: Colors.white)),
                  Text(
                    'URL: ${_spot!['DayImageUrl']}',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  if (_spot?['NightImageUrl'] != null) {
    images.add(
      CachedNetworkImage(
        imageUrl: _spot!['NightImageUrl'],
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) {
          print('Error loading night image: $error');
          return Container(
            color: Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white),
                  Text('Night Image Error', style: TextStyle(color: Colors.white)),
                  Text(
                    'URL: ${_spot!['NightImageUrl']}',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  if (images.isEmpty) {
    return Container(
      height: 250,
      color: Colors.grey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.white),
            Text('No images available', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  return SizedBox(
    height: 250,
    child: PageView(children: images),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_spot?['Title'] ?? 'Spot Details'),
        backgroundColor: const Color(0xFF162927),
      ),
      backgroundColor: const Color(0xFF162927),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      _buildImageGallery(),

                      
                      SizedBox(height: 20),
                      
                      // Spot Info
                      Text(
                        _spot?['Title'] ?? 'Unknown Spot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 10),
                      
                      Text(
                        _spot?['Description'] ?? 'No description',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Stats Row
                      Row(
                      children: [
                        // Each item wrapped in Expanded
                        Expanded(
                          child: _buildStatItem(
                            Icons.favorite, 
                            '${_spot?['FavoritesCount'] ?? 0} Likes'
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.people, 
                            '${_spot?['VisitCount'] ?? 0} Visits'
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.calendar_today, 
                            _spot?['CreatedAt'] != null 
                              ? DateFormat.yMd().format(DateTime.parse(_spot!['CreatedAt'])) 
                              : 'N/A'
                          ),
                        ),
                      ],
                    ),
                      
                      SizedBox(height: 20),
                      
                      // Weather Info
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.amber),
                          SizedBox(width: 10),
                           Flexible(
                          child: Text(
                            'Recommended Weather: ${_spot?['RecommendedWeather'] ?? 'Any'}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Like Button
                      Center(
                        child: ElevatedButton.icon(
                         onPressed: (_isLiked || _isLiking) ? null : _likeSpot,
                         icon: _isLiked
                                    ? Icon(Icons.favorite, color: Colors.red)
                                    : _isLiking 
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Icon(Icons.favorite_border),
                          label: Text(_isLiked ? 'Liked!' : 'Like this spot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDDA15E),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Reviews Section
                      Text(
                        'Reviews',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      Divider(color: Colors.white30),
                      
                      // Add Review
                      TextField(
                        controller: _reviewController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Write your review...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          suffixIcon: _isReviewing
                              ? CircularProgressIndicator()
                              : IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: _submitReview,
                                ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Reviews List
                      if (_reviews.isEmpty)
                        Center(
                          child: Text(
                            'No reviews yet',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            final createdAt = review['CreatedAt'] != null
                                ? DateTime.parse(review['CreatedAt'])
                                : null;
                            
                            return Card(
                              color: Color(0xFF283D3A),
                              margin: EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Icon(Icons.person, color: Colors.amber),
                                title: Text(
                                  review['Text'] ?? '',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: createdAt != null
                                    ? Text(
                                        DateFormat.yMMMd().add_jm().format(createdAt),
                                        style: TextStyle(color: Colors.white70),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '${review['Likes'] ?? 0}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Column(
       mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.amber),
      SizedBox(height: 5),
      // Add text wrapping with center alignment
      Text(
        text,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
        maxLines: 2, // Allow up to 2 lines
        overflow: TextOverflow.ellipsis, // Add ellipsis if too long
      ),
    ],
  );
  }
}