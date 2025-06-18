  import 'package:flutter/material.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'dart:async';
  import 'package:geolocator/geolocator.dart';
  import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

  class MapSearchController {
    final MapController mapController = MapController();
    final List<Marker> markers = [];
    List<LatLng> routePoints = [];
    bool isSearching = false;
    bool isLoadingRoute = false;
    LatLng? currentLocation;
    List<Marker> visitedMarkers = [];
    
    final _markersController = StreamController<List<Marker>>.broadcast();
    final _searchingController = StreamController<bool>.broadcast();
    final _errorController = StreamController<String>.broadcast();
    final _locationFoundController = StreamController<String>.broadcast();
    final _currentLocationController = StreamController<LatLng?>.broadcast();
    final _routeController = StreamController<List<LatLng>>.broadcast();
    final _routeLoadingController = StreamController<bool>.broadcast();
    final _boundingBoxController = StreamController<LatLngBounds>.broadcast();
    final _visitedSpotsController = StreamController<List<Marker>>.broadcast();
    
    Stream<List<Marker>> get visitedSpotsStream => _visitedSpotsController.stream;
    Stream<List<Marker>> get markersStream => _markersController.stream;
    Stream<bool> get searchingStream => _searchingController.stream;
    Stream<String> get errorStream => _errorController.stream;
    Stream<String> get locationFoundStream => _locationFoundController.stream;
    Stream<LatLng?> get currentLocationStream => _currentLocationController.stream;
    Stream<List<LatLng>> get routeStream => _routeController.stream;
    Stream<bool> get routeLoadingStream => _routeLoadingController.stream;
    Stream<LatLngBounds> get boundingBoxStream => _boundingBoxController.stream;
    

    StreamSubscription<Position>? _positionStreamSubscription;
    
 

    MapSearchController() {
      _markersController.add(markers);
      _routeController.add(routePoints);
    }
    
    void dispose() {
      _positionStreamSubscription?.cancel();
      _markersController.close();
      _searchingController.close();
      _errorController.close();
      _locationFoundController.close();
      _currentLocationController.close();
      _routeController.close();
      _routeLoadingController.close();
      _boundingBoxController.close();
       _visitedSpotsController.close();
    }
    
    void clearMarkers() {
    
    markers.removeWhere((marker) {
    
      if (marker.child is Column) {
        final column = marker.child as Column;
        return column.children.length != 2 || 
              column.children[1] is! ConstrainedBox;
      }
      return true; 
    });
    
    routePoints.clear();
    _markersController.add(markers);
    _routeController.add(routePoints);
    }
    
    Future<void> searchLocation(String query) async {
      if (query.isEmpty) return;
      
      isSearching = true;
      _searchingController.add(isSearching);

      try {
        
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
          ),
          headers: {
            'User-Agent': 'YourAppName/1.0', 
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data.isNotEmpty) {
            final result = data[0];
            final lat = double.parse(result['lat']);
            final lon = double.parse(result['lon']);
            final locationName = result['display_name'];
            final location = LatLng(lat, lon);
            
            
            markers.add(
              Marker(
                point: location,
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    if (currentLocation != null) {
                      calculateRoute(currentLocation!, location);
                    } else {
                      _errorController.add('Enable location to calculate route');
                    }
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFFDDA15E),
                        size: 40,
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          query,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            
            // Update markers
            _markersController.add(markers);
            
            // Move map to location
            mapController.move(location, 15.0);
            
            // Notify about found location
            _locationFoundController.add(locationName);
          } else {
            _errorController.add('No results found for "$query"');
          }
        } else {
          _errorController.add('Error searching for location');
        }
      } catch (e) {
        _errorController.add('Error: $e');
      } finally {
        isSearching = false;
        _searchingController.add(isSearching);
      }
    }
    
    Future<bool> _handleLocationPermission() async {
      bool serviceEnabled;
      LocationPermission permission;

      
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorController.add('Location services are disabled. Please enable the services');
        return false;
      }
      
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorController.add('Location permissions are denied');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _errorController.add('Location permissions are permanently denied, we cannot request permissions.');
        return false;
      }
      
      return true;
    }

    Future<void> getCurrentLocation() async {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      currentLocation = LatLng(position.latitude, position.longitude);
      _currentLocationController.add(currentLocation);
      
      _updateUserLocationMarker();
      
    
      mapController.move(currentLocation!, 15.0);
      
      _startLocationUpdates();
    } catch (e) {
      _errorController.add('Error getting current location: $e');
    }
    }
    
    void _startLocationUpdates() {
      
      _positionStreamSubscription?.cancel();
      
      
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, 
        ),
      ).listen((Position position) {
        currentLocation = LatLng(position.latitude, position.longitude);
        _currentLocationController.add(currentLocation);
        
        
        _updateUserLocationMarker();
      }, onError: (e) {
        _errorController.add('Error updating location: $e');
      });
    }
    
    void _updateUserLocationMarker() {
      if (currentLocation == null) return;
      
      
      // Create a new list instead of modifying the existing one
    final newMarkers = [...markers.where((m) => m.point != currentLocation)];
    
    // Add current location marker
    newMarkers.add(
      Marker(
        point: currentLocation!,
        width: 60,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withAlpha((0.3 * 255).toInt()),
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 30,
          ),
        ),
      ),
    );
    
    // Update markers with the new list
    markers.clear();
    markers.addAll(newMarkers);
    _markersController.add(markers);
    }
    
    Future<void> calculateRoute(LatLng start, LatLng end) async {
      isLoadingRoute = true;
      _routeLoadingController.add(isLoadingRoute);
      routePoints.clear();
      
      try {
        
        final response = await http.get(
          Uri.parse(
            'https://api.mapbox.com/directions/v5/mapbox/walking/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=polyline&access_token=${dotenv.env['MAPBOX_ACCESS_TOKEN']}',
          ),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final route = data['routes'][0];
            final polyline = route['geometry'];
            
            
            final List<PointLatLng> decodedPoints = 
                PolylinePoints().decodePolyline(polyline);
            
          
            routePoints = decodedPoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
            
          
            _routeController.add(routePoints);
            
            
            if (routePoints.isNotEmpty) {
              final bounds = LatLngBounds.fromPoints(routePoints);
              _boundingBoxController.add(bounds);
            }
            
            // Show route info
            final distance = (route['distance'] / 1000).toStringAsFixed(1); // km
            final duration = (route['duration'] / 60).toStringAsFixed(0); // minutes
            
            _locationFoundController.add('Route: $distance km, approx. $duration minutes');
          } else {
            _errorController.add('Could not calculate route');
          }
        } else {
          _errorController.add('Error calculating route');
        }
      } catch (e) {
        _errorController.add('Error: $e');
      } finally {
        isLoadingRoute = false;
        _routeLoadingController.add(isLoadingRoute);
      }
    }

    Future<void> loadVisitedSpots() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/visited-spots'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        visitedMarkers = data.map((visited) {
          final spot = visited['Spot'];
          return Marker(
            point: LatLng(spot['Latitude'], spot['Longitude']),
            width: 100,
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (currentLocation != null) {
                      calculateRoute(
                        currentLocation!,
                        LatLng(spot['Latitude'], spot['Longitude'])
                      );
                    }
                  },
                  child: Icon(Icons.check_circle, color: Colors.green, size: 40),
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
                        spot['Title'] ?? 'Visited Spot',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
        _visitedSpotsController.add(visitedMarkers);
      }
    } catch (e) {
      print('Failed to load visited spots: $e');
    }
  }

  }