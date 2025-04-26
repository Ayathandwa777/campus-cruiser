import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'YOUR_API_KEY', // From google-services.json
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cruiser',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<LatLng> _route = const [
    LatLng(-25.7545, 28.2316),
    LatLng(-25.7550, 28.2320),
    LatLng(-25.7555, 28.2325),
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Shuttle Tracker')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-25.7545, 28.2316),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('shuttle_1'),
            position: _route[_currentIndex],
            infoWindow: const InfoWindow(title: 'Campus Shuttle'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        },
        onMapCreated: (controller) => mapController = controller,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleShuttleMovement,
        child: Icon(_timer?.isActive ?? false 
            ? Icons.stop 
            : Icons.directions_bus),
      ),
    );
  }

  void _toggleShuttleMovement() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _updateShuttle());
    }
    setState(() {});
  }

  Future<void> _updateShuttle() async {
    _currentIndex = (_currentIndex + 1) % _route.length;
    
    await _firestore.collection('shuttles').doc('shuttle_1').set({
      'lat': _route[_currentIndex].latitude,
      'lng': _route[_currentIndex].longitude,
      'name': 'Campus Loop A',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLng(_route[_currentIndex]));
    });
  }
}