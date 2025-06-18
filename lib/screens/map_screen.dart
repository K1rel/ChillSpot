import 'package:domasna/screens/place_detail_screen.dart';
import 'package:domasna/services/spot_service.dart';
import 'package:domasna/services/visited_spot_service.dart';
import 'package:domasna/widgets/arrival_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../controllers/map_controller.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapSearchController controller = MapSearchController();
  final TextEditingController searchController = TextEditingController();
  List<Marker> markers = [];
  List<LatLng> routePoints = [];
  bool isSearching = false;
  bool isLoadingRoute = false;
  List<Marker> savedMarkers = [];  
  List<Marker> controllerMarkers = [];
  
  // Location tracking for arrival detection
  Timer? _locationCheckTimer;
  LatLng? _lastKnownLocation;
  Set<String> _shownPopups = {}; // Track which popups we've already shown
  
  @override
  void initState() {
    super.initState();
    
    controller.markersStream.listen((updatedMarkers) {
      setState(() {
        markers = updatedMarkers;
        controllerMarkers = updatedMarkers;
      });
    });
    
    controller.searchingStream.listen((searching) {
      setState(() {
        isSearching = searching;
      });
    });
    
    controller.routeLoadingStream.listen((loading) {
      setState(() {
        isLoadingRoute = loading;
      });
    });
    
    controller.routeStream.listen((points) {
      setState(() {
        routePoints = points;
      });
    });
    
    controller.boundingBoxStream.listen((bounds) {
      controller.mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    });
    
    controller.errorStream.listen((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    });
    
    controller.locationFoundStream.listen((locationName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locationName),
          duration: Duration(seconds: 3),
        ),
      );
    });
    
    // Listen to location updates for arrival detection
    controller.currentLocationStream.listen((location) {
      if (location != null) {
        _lastKnownLocation = location;
        _checkForNearbySpots(location);
      }
    });

    // Listen to visited spots updates from controller
    controller.visitedSpotsStream.listen((visitedMarkers) {
      setState(() {
        controller.visitedMarkers = visitedMarkers;
      });
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.getCurrentLocation();
      await _loadSavedSpots();
      controller.loadVisitedSpots(); // Use controller's method
      _startLocationTracking();
    });
  }
  
  void _startLocationTracking() {
    // Check for nearby spots every 30 seconds
    _locationCheckTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_lastKnownLocation != null) {
        _checkForNearbySpots(_lastKnownLocation!);
      }
    });
  }

 Future<void> _checkForNearbySpots(LatLng currentLocation) async {
  print('[PROXIMITY] Checking at: ${currentLocation.latitude}, ${currentLocation.longitude}');
  
  try {
    final nearbySpots = await VisitedSpotService.checkProximity(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    
    print('[PROXIMITY] Found ${nearbySpots.length} nearby spots');
    
    for (final spot in nearbySpots) {
      print('[PROXIMITY] Nearby spot: ${spot.title} (${spot.distance}m)');
      
      if (!_shownPopups.contains(spot.spotId)) {
        print('[PROXIMITY] Showing popup for: ${spot.title}');
        _shownPopups.add(spot.spotId);
        _showArrivalPopup(spot);
        break;
      }
    }
  } catch (e) {
    print('[PROXIMITY] Error: $e');
  }
}
  
  void _showArrivalPopup(NearbySpot nearbySpot) {
  showArrivalPopup(
    context,
    nearbySpot,
    () {
      // After marking as visited, reset the shown state
      _shownPopups.remove(nearbySpot.spotId);
      controller.loadVisitedSpots();
    },
  );
}
  
  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    _locationCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to view saved spots')),
      );
      return;
    }

    try {
      final spots = await SpotService.getSpotsByUserId();
      setState(() {
        savedMarkers = spots.map((spot) {
          return Marker(
            point: LatLng(spot['Latitude'], spot['Longitude']),
            width: 100,
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.currentLocation != null) {
                      controller.calculateRoute(
                        controller.currentLocation!,
                        LatLng(spot['Latitude'], spot['Longitude'])
                      );
                    }
                  },
                  child: Icon(Icons.location_on, color: Color(0xFFDDA15E), size: 40),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 40, maxWidth: 100),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        spot['Title'] ?? 'Saved Spot',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load saved spots: $e')),
      );
    }
  }

  void _addMarker(LatLng point) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlaceDetailScreen(
        location: point,
        onSave: (placeDetails) async {  
          await _loadSavedSpots();
          
          // Trigger immediate proximity check after saving
          if (controller.currentLocation != null) {
            _checkForNearbySpots(controller.currentLocation!);
          }
        },
      ),
    ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: const LatLng(41.9981, 21.4254),
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                _addMarker(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  if (routePoints.isNotEmpty)
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                ],
              ),
              MarkerLayer(markers: [
                ...savedMarkers,
                ...controller.visitedMarkers, // Use controller's visited markers
                ...controllerMarkers,
              ]),
            ],
          ),
          // Search bar
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDA15E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Search...",
                              border: InputBorder.none,
                              suffixIcon: isSearching
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    padding: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black54,
                                    ),
                                  )
                                : null,
                            ),
                            onSubmitted: (value) {
                              controller.searchLocation(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDDA15E),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    color: Colors.black,
                    onPressed: () {
                      controller.searchLocation(searchController.text);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Legend for different marker types
          Positioned(
            top: 100,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFDDA15E), size: 16),
                      SizedBox(width: 5),
                      Text('Saved Spots', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 5),
                      Text('Visited', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDDA15E),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          // Current location button
          Positioned(
            bottom: 100,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDDA15E),
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location),
                color: Colors.black,
                onPressed: () {
                  controller.getCurrentLocation();
                },
              ),
            ),
          ),
          // Clear button
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDDA15E),
              ),
              child: IconButton(
                icon: const Icon(Icons.layers_clear),
                color: Colors.black,
                onPressed: () {
                  controller.clearMarkers();
                },
              ),
            ),
          ),
          // Refresh visited spots button
          Positioned(
            bottom: 100,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF606C38),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh),
                color: Colors.white,
                onPressed: () {
                  controller.loadVisitedSpots();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Refreshed visited spots')),
                  );
                },
              ),
            ),
          ),
          // Loading indicator for route calculation
          if (isLoadingRoute)
            Positioned(
              bottom: 180,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("Calculating route..."),
                  ],
                ),
              ),
            ),
          // Route legend - shows when a route is active
          if (routePoints.isNotEmpty)
            Positioned(
              top: 170,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 3,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text("Route", style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          routePoints = [];
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}