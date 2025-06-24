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
      
      final prefs = await SharedPreferences.getInstance();
      final likedSpots = prefs.getStringList('liked_spots') ?? [];
      likedSpots.add(widget.spotId);
      await prefs.setStringList('liked_spots', likedSpots);

      setState(() {
        _isLiked = true;
        if (_spot != null) {
          _spot = {
            ..._spot!,
            'FavoritesCount': (_spot!['FavoritesCount'] ?? 0) + 1,
          };
        }
      });
      
      await _loadSpotDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like spot: $e'),
          backgroundColor: Colors.red,
        ),
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
      await _loadSpotDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: _spot!['DayImageUrl'],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFDDA15E)),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text('Day Image Error', 
                           style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    if (_spot?['NightImageUrl'] != null) {
      images.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: _spot!['NightImageUrl'],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFDDA15E)),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text('Night Image Error', 
                           style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    if (images.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
              SizedBox(height: 12),
              Text('No images available', 
                   style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 250,
      child: PageView(
        children: images,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_spot?['Title'] ?? 'Spot Details', 
                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF162927),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF162927),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFDDA15E)))
          : _error != null
              ? Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(_error!, 
                               style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      _buildImageGallery(),
                      
                      SizedBox(height: 24),
                      
                      // Spot Info Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF283D3A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _spot?['Title'] ?? 'Unknown Spot',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            SizedBox(height: 12),
                            
                            Text(
                              _spot?['Description'] ?? 'No description',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9), 
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Stats Row
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF283D3A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                Icons.favorite, 
                                '${_spot?['FavoritesCount'] ?? 0}',
                                'Likes',
                                Colors.red,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                Icons.people, 
                                '${_spot?['VisitCount'] ?? 0}',
                                'Visits',
                                Colors.blue,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                Icons.calendar_today, 
                                _spot?['CreatedAt'] != null 
                                  ? DateFormat.yMd().format(DateTime.parse(_spot!['CreatedAt'])) 
                                  : 'N/A',
                                'Created',
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Weather Info
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF283D3A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.wb_sunny, color: Colors.amber, size: 24),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recommended Weather',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7), 
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${_spot?['RecommendedWeather'] ?? 'Any'}',
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Like Button
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: (_isLiked || _isLiking) ? null : _likeSpot,
                            icon: _isLiked
                                ? Icon(Icons.favorite, color: Colors.red, size: 24)
                                : _isLiking 
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(Icons.favorite_border, color: Colors.white, size: 24),
                            label: Text(
                              _isLiked ? 'Liked!' : 'Like this spot',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _isLiked ? Colors.red : Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLiked 
                                  ? Colors.white 
                                  : Color(0xFFDDA15E),
                              foregroundColor: _isLiked ? Colors.red : Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Reviews Section
                      Text(
                        'Reviews',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Add Review
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF283D3A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Write a review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _reviewController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Share your experience...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFDDA15E), width: 2),
                                ),
                                filled: true,
                                fillColor: Color(0xFF162927),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _isReviewing ? null : _submitReview,
                                icon: _isReviewing
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(Icons.send, size: 18),
                                label: Text(_isReviewing ? 'Posting...' : 'Post Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFDDA15E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Reviews List
                      if (_reviews.isEmpty)
                        Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Color(0xFF283D3A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, 
                                     size: 48, color: Colors.white.withOpacity(0.5)),
                                SizedBox(height: 16),
                                Text(
                                  'No reviews yet',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to share your experience!',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _reviews.map((review) {
                            final createdAt = review['CreatedAt'] != null
                                ? DateTime.parse(review['CreatedAt'])
                                : null;
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFF283D3A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.person, 
                                                 color: Colors.amber, size: 20),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Anonymous User',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (createdAt != null)
                                              Text(
                                                DateFormat.yMMMd().add_jm().format(createdAt),
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.favorite, 
                                               color: Colors.red, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            '${review['Likes'] ?? 0}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    review['Text'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}