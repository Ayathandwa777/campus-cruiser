// lib/services/firestore_service.dart

// We import the cloud_firestore package to talk to our database.
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // We get an instance of our Firestore database.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This function will return a continuous "stream" of data.
  // Think of it as a live feed or a conveyor belt of information.
  // Whenever the 'shuttles' collection changes in our database, this
  // stream will send the new data to our app automatically.
  Stream<QuerySnapshot> getShuttlesStream() {
    return _firestore.collection('shuttles').snapshots();
  }
}