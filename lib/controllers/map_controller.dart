import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapSearchController {
  final MapController mapController = MapController();
  final List<Marker> markers = [];
  List<LatLng> routePoints = [];
  bool isSearching = false;
  bool isLoadingRoute = false;
  LatLng? currentLocation;
  
  
  final _markersController = StreamController<List<Marker>>.broadcast();
  final _searchingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _locationFoundController = StreamController<String>.broadcast();
  final _currentLocationController = StreamController<LatLng?>.broadcast();
  final _routeController = StreamController<List<LatLng>>.broadcast();
  final _routeLoadingController = StreamController<bool>.broadcast();
  final _boundingBoxController = StreamController<LatLngBounds>.broadcast();
  
  
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
  }
  
  void clearMarkers() {
    markers.clear();
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
    
    
    markers.removeWhere((marker) => marker.point == currentLocation);
    
   
    markers.add(
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
}