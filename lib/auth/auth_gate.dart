// =============================================================================
// || FILE: lib/auth/auth_gate.dart                                           ||
// || PURPOSE: This is the final, smartest version of our AuthGate. It now    ||
// ||          checks not only if the user is logged in, but also if their    ||
// ||          email address has been verified by clicking the link.          ||
// =============================================================================

// --- IMPORTS ---
// We import Firebase Auth to listen to authentication state changes.
import 'package:firebase_auth/firebase_auth.dart';
// We import Flutter's Material library for UI widgets like Scaffold.
import 'package:flutter/material.dart';
// We import the three possible destinations: Login, Verify Email, and Map.
import 'package:campus_cruiser/screens/login_screen.dart'; // Ensure correct path
import 'package:campus_cruiser/screens/map_screen.dart'; // Ensure correct path
import 'package:campus_cruiser/screens/verify_email_screen.dart'; // Ensure correct path

// AuthGate remains a StatelessWidget because it doesn't hold any state itself.
// Its only job is to listen to the auth stream and decide which screen to show.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold as the base layout.
    return Scaffold(
      // The core of the AuthGate is the StreamBuilder.
      body: StreamBuilder<User?>( // The stream emits `User` objects or `null`.
        // --- The Stream ---
        // `FirebaseAuth.instance.authStateChanges()` is the "radio station".
        // It automatically broadcasts the current `User` object whenever someone
        // logs in or logs out. If logged out, it broadcasts `null`.
        stream: FirebaseAuth.instance.authStateChanges(),

        // --- The Builder ---
        // This function runs every time a new value (User or null) comes from the stream.
        // The `snapshot` object contains the latest broadcasted value.
        builder: (context, snapshot) {
          // --- Check 1: Is the user logged IN? ---
          // `snapshot.hasData` is true if the stream broadcasted a `User` object
          // (meaning someone is logged in).
          if (snapshot.hasData) {
            // If logged in, we grab the actual User object.
            User? user = snapshot.data;

            // --- Check 2: Is the logged-in user's EMAIL VERIFIED? ---
            // We safely check if the user object exists (`user != null`) and then
            // check its `emailVerified` property (which is true or false).
            if (user != null && user.emailVerified) {
              // --- STATE: Logged In + Verified ---
              // If they are logged in AND verified, show the main MapScreen.
              print("AuthGate: User logged in and verified. Showing MapScreen.");
              return const MapScreen();
            } else {
              // --- STATE: Logged In + NOT Verified ---
              // If they are logged in BUT their email is NOT verified,
              // show the VerifyEmailScreen to prompt them.
              print("AuthGate: User logged in but NOT verified. Showing VerifyEmailScreen.");
              return const VerifyEmailScreen();
            }
          }
          
          // --- Check 3: Is the user logged OUT? ---
          // If `snapshot.hasData` is false, it means the stream broadcasted `null`.
          else {
            // --- STATE: Logged Out ---
            // Show the LoginScreen.
            print("AuthGate: User logged out. Showing LoginScreen.");
            return const LoginScreen();
          }
        },
      ),
    );
  }
}