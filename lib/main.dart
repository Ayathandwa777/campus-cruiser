// -----------------------------------------------------------------------------
// FILE: lib/main.dart
// PURPOSE: This is the absolute starting point of your entire application.
// Think of it as the "ignition key" for a car. When the user taps the
// UniVerse app icon, this is the very first file that gets executed.
// -----------------------------------------------------------------------------

// We start by "importing" the toolkits we need.
// 'package:flutter/material.dart' is the main toolkit for building the User Interface (UI).
import 'package:flutter/material.dart';
// This toolkit lets us connect to our Firebase backend.
import 'package:firebase_core/firebase_core.dart';
import 'package:campus_cruiser/auth/auth_gate.dart';
// This imports the secret keys file that connects us to our specific Firebase project.
import 'firebase_options.dart';

// The "main" function is the true front door of the app.
// We mark it as "async" because it needs to wait for Firebase to connect
// before it can continue.
void main() async {
  // --- SETUP PHASE ---
  // Before we can run the app, we need to do some important setup.

  // 1. A safety check. This line makes sure Flutter's engine is ready
  //    before we try to do anything advanced like talking to Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. The official "handshake" with Firebase.
  //    The "await" keyword tells the app: "Pause right here and do not
  //    continue until Firebase is fully connected and ready."
  await Firebase.initializeApp(
    // We tell it to use the keys from our 'firebase_options.dart' file.
    options: defaultFirebaseOptions,
  );
  
  // --- RUN PHASE ---
  // Now that the setup is complete, we can finally run our app.
  runApp(const MyApp());
}

// "MyApp" is our very first custom widget.
// Think of it as the main container that holds our entire application.
// It's a "StatelessWidget" because it just displays information; it doesn't
// need to manage any changing data itself.
// lib/main.dart

// ... (keep the existing imports and main function)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the maroon color. You can adjust this hex code if needed.
    // The '0xFF' prefix is needed to specify opacity (FF = fully opaque).
    const Color vulumziMaroon = Color(0xFF800000);

    return MaterialApp( // Change this from 'const MaterialApp'
      title: 'UniVerse', // Update the app title
      debugShowCheckedModeBanner: false,
      
      // --- NEW CODE: Applying the Theme ---
      theme: ThemeData(
        // Set the primary color swatch. This automatically colors many widgets,
        // including the AppBar background and ElevatedButton background.
        // We use MaterialColor to provide shades, but a simple primaryColor works too.
        primarySwatch: MaterialColor(vulumziMaroon.value, const <int, Color>{
           50: vulumziMaroon,
          100: vulumziMaroon,
          200: vulumziMaroon,
          300: vulumziMaroon,
          400: vulumziMaroon,
          500: vulumziMaroon, // Your primary color
          600: vulumziMaroon,
          700: vulumziMaroon,
          800: vulumziMaroon,
          900: vulumziMaroon,
        }),
        
        // You might also want to set the AppBar theme specifically
        // if primarySwatch doesn't give the exact look you want.
        appBarTheme: const AppBarTheme(
          backgroundColor: vulumziMaroon, // Explicitly set AppBar background
          foregroundColor: Colors.white, // Set the title text color to white for contrast
        ),

        // You can customize button themes too if needed
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: vulumziMaroon, // Button background color
            foregroundColor: Colors.white, // Button text color
          ),
        ),
        
        // Use Material 3 design features (optional but recommended)
        useMaterial3: true,
      ),
      // --- END OF NEW THEME CODE ---

      home: const AuthGate(), // Your AuthGate remains the entry point
    );
  }
}