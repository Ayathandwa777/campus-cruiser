import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:campus_cruiser/screens/login_screen.dart';
import 'firebase_options.dart'; // The file we created manually with your keys

void main() async {
  // This line is required to ensure Flutter is ready before Firebase starts.
  WidgetsFlutterBinding.ensureInitialized();
  
  // This initializes your app's connection to your Firebase project.
  await Firebase.initializeApp(
    options: defaultFirebaseOptions,
  );
  
  // This runs your app.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'UniVerse',
      debugShowCheckedModeBanner: false, // This removes the top-right debug banner
      home: LoginScreen(), // This sets the first screen to be your login page
    );
  }
}
