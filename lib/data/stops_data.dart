// lib/data/stops_data.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

// A simple class to represent a Bus Stop
class BusStop {
  final String id;
  final String name;
  final LatLng position;

  BusStop({required this.id, required this.name, required this.position});
}

// The official list of stops for the pilot route
final List<BusStop> appBusStops = [
  BusStop(
    id: 'amic_deck',
    name: 'Amic Deck',
    position: LatLng(-26.1929, 28.0305), 
  ),
  BusStop(
    id: 'yale_road',
    name: 'Yale Road North',
    position: LatLng(-26.1915, 28.0295),
  ),
  BusStop(
    id: 'knockando',
    name: 'Knockando Halls',
    position: LatLng(-26.1885, 28.0345), // Approximate location
  ),
  BusStop(
    id: 'junction',
    name: 'Wits Junction',
    position: LatLng(-26.1850, 28.0380),
  ),
];