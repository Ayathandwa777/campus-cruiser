// =============================================================================
// || FILE: lib/screens/login_screen.dart                                     ||
// || PURPOSE: Final polished login/signup screen. This version adds basic    ||
// ||          frontend validation for email format and password length.      ||
// =============================================================================

import 'package:flutter/material.dart';
import 'package:campus_cruiser/services/auth_services.dart'; // Ensure correct path if needed

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- STATE VARIABLES ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true; // Start in Login mode
  bool _isLoading = false;  // Track loading state

  // --- METHODS (The Screen's Actions) ---


// --- NEW METHOD: Forgot Password ---
void _forgotPassword() async {
  // We only need the email for password reset.
  final email = _emailController.text.trim();

  // Basic validation: Is the email field empty?
  if (email.isEmpty) {
    _showErrorDialog("Please enter your email address first.");
    return;
  }
  // Basic validation: Does it look like an email?
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(email)) {
    _showErrorDialog("Please enter a valid email address.");
    return;
  }

  // Show a loading indicator (optional but good UX)
  setState(() { _isLoading = true; });

  final authService = AuthService();
  String? resultMessage; // To store success or error message

  try {
    resultMessage = await authService.sendPasswordResetEmail(email);
  } catch (e) {
    resultMessage = "An unexpected error occurred.";
  } finally {
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // Show result message using a SnackBar
  if (mounted && resultMessage != null) {
    // If resultMessage is NOT null, it means an ERROR occurred.
     _showErrorDialog(resultMessage); // Use the existing dialog for errors
  } else if (mounted) {
     // If resultMessage IS null, it means SUCCESS.
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox!'),
          backgroundColor: Colors.green,
        ),
      );
  }
}

  // Main function called when the user presses the Login/Sign Up button.
  void _submitForm() async {
    // 1. --- Read Input ---
    // Get the text from the fields and use .trim() to remove extra spaces.
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // =======================================================================
    // || NEW CODE: Frontend Form Validation                                  ||
    // =======================================================================
    // We perform these checks *before* showing the loading spinner or
    // contacting Firebase. This provides instant feedback to the user.

    // --- Check 1: Are fields empty? ---
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both email and password.");
      return; // Stop the function here.
    }

    // --- Check 2: Does the email look valid? ---
    // This is a simple check. It uses a "Regular Expression" (RegExp)
    // pattern to see if the email string contains an "@" and a "."
    // in the right places. It's not foolproof but catches most typos.
    // Explanation of RegExp: r'^[^@]+@[^@]+\.[^@]+$'
    // ^      - Start of the string
    // [^@]+  - One or more characters that are NOT "@"
    // @      - The literal "@" symbol
    // [^@]+  - One or more characters that are NOT "@"
    // \.     - The literal "." symbol (needs escaping with \)
    // [^@]+  - One or more characters that are NOT "@"
    // $      - End of the string
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showErrorDialog("Please enter a valid email address.");
      return; // Stop the function here.
    }

    // --- Check 3: Is the password long enough? ---
    // Firebase requires passwords to be at least 6 characters.
    if (password.length < 6) {
      _showErrorDialog("Password must be at least 6 characters long.");
      return; // Stop the function here.
    }
    // =======================================================================
    // || END OF NEW VALIDATION CODE                                          ||
    // =======================================================================

    // If all validation checks pass, we proceed with showing the spinner
    // and calling the AuthService.
    setState(() { _isLoading = true; });

    final authService = AuthService();
    String? errorMessage;

    try {
      if (_isLoginMode) {
        errorMessage = await authService.signInWithEmailAndPassword(email, password);
      } else {
        errorMessage = await authService.signUpWithEmailAndPassword(email, password);
      }
    } catch (e) {
      errorMessage = "An unexpected error occurred: $e";
    } finally {
      // Ensure the widget is still mounted before updating state.
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
    
    // Show error dialog if an error message was returned from AuthService.
    if (errorMessage != null && mounted) {
      _showErrorDialog(errorMessage);
    }
    // If errorMessage is null, login/signup was successful, and AuthGate handles navigation.
  }

  // Helper function to show a simple error popup (AlertDialog).
  void _showErrorDialog(String message) {
    // Ensure the context is still valid before showing the dialog.
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () { Navigator.of(ctx).pop(); }, // Close the dialog
          )
        ],
      ),
    );
  }
  
  // Function to switch between Login and Sign Up modes.
  void _toggleMode() {
    setState(() { _isLoginMode = !_isLoginMode; });
  }

  // Clean up controllers when the screen is removed.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- THE UI ---
  // The build method remains the same, showing either the spinner or the form.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'UniVerse Login' : 'UniVerse Sign Up'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show spinner if loading
            : Column( // Show form if not loading
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress, // Keyboard hint
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true, // Hide password text
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _submitForm, // Call our main submit function
                    child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                  ),
                  const SizedBox(height: 10),
                  // --- NEW CODE: Forgot Password Button ---
                  // Only show this button when in LOGIN mode.
                  if (_isLoginMode)
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,// Align to the center
                      children: [
                        TextButton(
                          onPressed: _forgotPassword, // We'll create this function next
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _toggleMode, // Call function to switch mode
                    child: Text(_isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login"),
                  )
                ],
              ),
      ),
    );
  }
}