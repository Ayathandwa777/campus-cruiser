// =============================================================================
// || FILE: lib/screens/verify_email_screen.dart                              ||
// || PURPOSE: This screen is shown to users who have successfully signed up  ||
// ||          but have not yet clicked the verification link sent to their   ||
// ||          email. It provides instructions and options.                   ||
// =============================================================================

// We import the standard Flutter UI toolkit.
import 'package:flutter/material.dart';
// We import Firebase Auth to access the current user and resend emails.
import 'package:firebase_auth/firebase_auth.dart';
// We import our AuthService to handle signing out.
import 'package:campus_cruiser/services/auth_services.dart'; // Ensure correct path if needed

// This screen can be a "StatelessWidget" for now because it primarily just
// displays information and triggers actions (resend, logout) handled elsewhere.
// If we added more complex logic (like a timer), we might change it later.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  // --- METHODS (The Screen's Actions) ---

  // Function to resend the verification email.
  Future<void> _resendVerificationEmail(BuildContext context) async {
    // We get the currently logged-in user from FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;

    // Check if we actually have a logged-in user.
    if (user != null) {
      try {
        // Call Firebase's function to send the email again.
        await user.sendEmailVerification();
        print("Verification email resent successfully!");

        // Show a confirmation message using a SnackBar.
        // We check `context.mounted` to ensure the screen is still visible.
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent. Please check your inbox.'),
              backgroundColor: Colors.green, // Use a green background for success
            ),
          );
        }
      } catch (e) {
        // If sending fails, show an error SnackBar.
        print("ERROR RESENDING EMAIL: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resending email: $e'),
              backgroundColor: Colors.red, // Use a red background for errors
            ),
          );
        }
      }
    }
  }

  // Function to sign the user out.
  void _signOut() {
    // We simply call the signOut method from our AuthService.
    // The AuthGate will automatically redirect to the LoginScreen.
    final authService = AuthService();
    authService.signOut();
  }


  // --- THE UI (What The User Sees) ---
  @override
  Widget build(BuildContext context) {
    // We use a Scaffold for the basic screen layout.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        // Optionally add a back button or automatically imply one if needed
      ),
      // We use Padding to add some space around the content.
      body: Padding(
        padding: const EdgeInsets.all(20.0), // 20 pixels of padding on all sides
        child: Center( // Center the content vertically and horizontally
          child: Column(
            // Align content in the center vertically.
            mainAxisAlignment: MainAxisAlignment.center,
            // Align text to the center horizontally.
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Informational Text ---
              const Icon(
                Icons.email_outlined, // Display an email icon
                size: 80, // Make the icon large
                color: Colors.blueAccent, // Give it a color
              ),
              const SizedBox(height: 20), // Space between icon and text
              const Text(
                'Verify Your Email Address',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15), // Space between title and body text
              Text(
                // Try to display the user's email for clarity.
                // `FirebaseAuth.instance.currentUser?.email` safely gets the email
                // or returns null if the user isn't available for some reason.
                'A verification link has been sent to:\n${FirebaseAuth.instance.currentUser?.email ?? 'your email address'}.\n\nPlease check your inbox (and spam folder!) and click the link to activate your account.',
                textAlign: TextAlign.center, // Center the text
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30), // Space before the buttons

              // --- Action Buttons ---

              // Button to resend the verification email.
              ElevatedButton.icon(
                icon: const Icon(Icons.send), // Add a send icon
                label: const Text('Resend Verification Email'),
                // When pressed, call our _resendVerificationEmail function.
                // We pass `context` so it can show SnackBars.
                onPressed: () => _resendVerificationEmail(context),
              ),
              const SizedBox(height: 10), // Space between buttons

              // Button to allow the user to log out / cancel.
              TextButton(
                child: const Text('Cancel / Log Out'),
                // When pressed, call our _signOut function.
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}