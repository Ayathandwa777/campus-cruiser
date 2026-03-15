// =============================================================================
// || FILE: lib/screens/map_screen.dart                                       ||
// || PURPOSE: The Master Map Screen. It handles:                             ||
// ||          1. Real-time Bus Tracking (Firestore)                          ||
// ||          2. User Location (Geolocator)                                  ||
// ||          3. Route Visualization (Polylines)                             ||
// ||          4. Math Logic: Nearest Stop & ETA Calculation                  ||
// =============================================================================

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // For GPS logic
import 'package:campus_cruiser/services/auth_services.dart';
import 'package:campus_cruiser/services/firestore_service.dart';
import 'package:campus_cruiser/data/route_data.dart'; // Route coordinates
import 'package:campus_cruiser/data/stops_data.dart'; // Stop coordinates
import 'package:campus_cruiser/screens/driver_screen.dart';

// --- THE WIDGET DEFINITION ---
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

// --- THE STATE CLASS ---
class _MapScreenState extends State<MapScreen> {
  // --- SERVICE INSTANCES ---
  final FirestoreService _firestoreService = FirestoreService();
  
  // --- MAP CONSTANTS ---
  static const CameraPosition _witsUniversity = CameraPosition(
    target: LatLng(-26.1922, 28.0300), 
    zoom: 15.5
  );

  // --- ETA PHYSICS CONSTANTS (The Math Rules) ---
  // Average bus speed: 30 km/h ~= 500 meters per minute.
  static const double _busSpeedMetersPerMin = 500.0;
  // A buffer to account for traffic lights and passenger boarding time.
  static const int _trafficBufferMinutes = 2;

  // --- STATE VARIABLES (The Screen's Memory) ---
  BitmapDescriptor? _busIcon; // Holds the custom image
  final Set<Polyline> _polylines = {}; // Holds the route lines
  
  // New: Where is the student right now?
  Position? _currentUserLocation; 
  
  // New: Strings to display on the UI Card
  String _nearestStopName = "Locating you...";
  String _liveETA = "Waiting for bus...";


  // --- LIFECYCLE METHODS ---
  @override
  void initState() {
    super.initState();
    _loadCustomIcon();       // 1. Get the bus image
    _showWelcomeSnackBar();  // 2. Say hello
    _createRouteLine();      // 3. Draw the maroon line
    _requestLocationPermission(); // 4. Ask for GPS & Start Tracking User
  }

  // ===========================================================================
  // || SECTION 1: PERMISSIONS & USER LOCATION                                ||
  // ===========================================================================
  
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // If we get here, we have permission!
    // Get the current high-accuracy position.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // Save the user's location to our state variable so other functions can use it.
    setState(() {
      _currentUserLocation = position;
    });

    // Immediately calculate which stop is closest to them.
    _findNearestStop(position);
  }

  // ===========================================================================
  // || SECTION 2: THE MATH (Nearest Stop & ETA)                              ||
  // ===========================================================================

  // Logic: Loop through all stops, measure distance, find the winner.
  void _findNearestStop(Position userLocation) {
    double minDistance = double.infinity;
    String closestStop = "Unknown";

    for (var stop in appBusStops) {
      double distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        stop.position.latitude,
        stop.position.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestStop = stop.name;
      }
    }

    if (mounted) {
      setState(() {
        _nearestStopName = closestStop;
      });
    }
  }

  // Logic: Measure distance to bus, apply "Road Factor", divide by Speed.
  void _calculateETA(LatLng busLocation, Position userLocation) {
    // 1. Straight line distance (in meters)
    double straightDistance = Geolocator.distanceBetween(
      busLocation.latitude,
      busLocation.longitude,
      userLocation.latitude,
      userLocation.longitude,
    );

    // 2. Road Factor (Roads are curvy, roughly 1.4x longer than a straight line)
    double roadDistance = straightDistance * 1.4;

    // 3. Time = Distance / Speed
    double timeInMinutes = roadDistance / _busSpeedMetersPerMin;

    // 4. Total = Time + Buffer
    double totalTime = timeInMinutes + _trafficBufferMinutes;

    // 5. Update the UI text
    setState(() {
      _liveETA = "${totalTime.ceil()} mins"; // Round up to nearest minute
    });
  }

  // ===========================================================================
  // || SECTION 3: MAP ASSETS (Icons & Lines)                                 ||
  // ===========================================================================

  void _createRouteLine() {
    final Polyline routeLine = Polyline(
      polylineId: const PolylineId('wits_circuit'),
      points: witsRoutePoints, // From data/route_data.dart
      color: const Color(0xFF800000), // Maroon
      width: 5,
    );
    setState(() {
      _polylines.add(routeLine);
    });
  }

  Future<void> _loadCustomIcon() async {
    try {
      const double iconSize = 55.0; 
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(iconSize, iconSize)),
        'assets/images/bus_icon.png',
      );
      if (mounted) {
        setState(() { _busIcon = icon; });
      }
    } catch (e) {
      print("Error loading custom bus icon: $e");
    }
  }

  // ===========================================================================
  // || SECTION 4: UI & BUILD METHOD                                          ||
  // ===========================================================================

  void _showWelcomeSnackBar() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to UniVerseGo!'), duration: Duration(seconds: 3)),
        );
      }
    });
  }

  void signOut() {
    final AuthService authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniVerseGo Live Map'),
        actions:  [
  IconButton(
    icon: const Icon(Icons.directions_bus),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriverScreen()),
    ),
  ),
  IconButton(icon: const Icon(Icons.logout), onPressed: signOut),
],
        
      ),
      
      // We use a STACK to float the Info Card on top of the Map.
      body: Stack(
        children: [
          // --- LAYER 1: The Map (Bottom) ---
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getShuttlesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final Set<Marker> markers = {};
              
              // If we have shuttle data...
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final lat = (data['lat'] is num) ? (data['lat'] as num).toDouble() : -26.1922;
                  final lng = (data['lng'] is num) ? (data['lng'] as num).toDouble() : 28.0300;

                  // --- CRITICAL STEP: Run the Math ---
                  // Every time the bus moves, we recalculate the ETA based on
                  // the bus's new position (lat/lng) and the user's saved position.
                  if (_currentUserLocation != null) {
                    // Note: In a real app with multiple buses, we'd find the CLOSEST bus.
                    // For the pilot with 1 bus, this simple logic works perfectly.
                    _calculateETA(LatLng(lat, lng), _currentUserLocation!);
                  }

                  // Create the marker
                  final shuttleMarker = Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(lat, lng),
                    infoWindow: InfoWindow(title: data['name'] ?? 'Shuttle'),
                    icon: _busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  );
                  markers.add(shuttleMarker);
                }
              }

              return GoogleMap(
                initialCameraPosition: _witsUniversity,
                myLocationEnabled: true, // Show blue dot
                myLocationButtonEnabled: true, // Button to center on user
                markers: markers,
                polylines: _polylines,
              );
            },
          ),

          // --- LAYER 2: The Info Card (Top) ---
          Positioned(
            bottom: 30, // Distance from bottom
            left: 20,
            right: 20,
            child: Card(
              elevation: 8, // Shadow
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Left Side: Nearest Stop
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("NEAREST STOP", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 5),
                        Text(_nearestStopName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // Vertical Divider
                    Container(height: 40, width: 1, color: Colors.grey.shade300),
                    // Right Side: ETA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("ARRIVING IN", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 5),
                        Text(_liveETA, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF800000))),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}