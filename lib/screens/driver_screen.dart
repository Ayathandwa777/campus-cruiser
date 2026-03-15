// =============================================================================
// || FILE: lib/screens/driver_screen.dart
// || PURPOSE: The driver-side screen. One button to start/stop sharing
// ||          live GPS coordinates to Firestore every 5 seconds.
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  bool _isSharing = false;
  Timer? _locationTimer;
  String _statusMessage = "Press Start to begin sharing your location.";

  // The Firestore document we write to — student app reads from this
  final _shuttleDoc = FirebaseFirestore.instance
      .collection('shuttles')
      .doc('vulumzi_bus_1');

  // --- START SHARING ---
  Future<void> _startSharing() async {
    // 1. Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _statusMessage = "Location permission denied."; });
        return;
      }
    }

    setState(() {
      _isSharing = true;
      _statusMessage = "Sharing live location...";
    });

    // 2. Send location every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await _shuttleDoc.set({
          'name': 'Vulumzi Shuttle',
          'lat': position.latitude,
          'lng': position.longitude,
          'last_updated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _statusMessage =
                "✅ Live — Last update:\nLat: ${position.latitude.toStringAsFixed(5)}\nLng: ${position.longitude.toStringAsFixed(5)}";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() { _statusMessage = "Error getting location: $e"; });
        }
      }
    });
  }

  // --- STOP SHARING ---
  void _stopSharing() {
    _locationTimer?.cancel();
    setState(() {
      _isSharing = false;
      _statusMessage = "Location sharing stopped.";
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniVerse — Driver Mode'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status icon
              Icon(
                _isSharing ? Icons.location_on : Icons.location_off,
                size: 80,
                color: _isSharing ? const Color(0xFF800000) : Colors.grey,
              ),
              const SizedBox(height: 30),

              // Status message
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Start / Stop button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSharing ? _stopSharing : _startSharing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSharing ? Colors.red : const Color(0xFF800000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _isSharing ? 'Stop Sharing' : 'Start Sharing Location',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}