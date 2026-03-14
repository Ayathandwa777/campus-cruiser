// =============================================================================
// || FILE: lib/services/auth_service.dart                                    ||
// || PURPOSE: This version adds the automatic sending of a verification      ||
// ||          email immediately after a user successfully signs up.          ||
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // We get our instance of FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- SIGN IN ---
  // This function remains the same. It returns null on success, error string on failure.
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print("FIREBASE ERROR (SIGN IN): ${e.code}");
      return _getErrorMessage(e.code); // Return user-friendly error
    }
  }

  // --- SIGN UP ---
  // This function is updated to send the verification email.
  Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // 1. --- Create the User ---
      // We first try to create the user account in Firebase Auth.
      // The `await` keyword pauses execution until Firebase responds.
      // If this fails (e.g., email already exists), it will jump to the `catch` block.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the line above succeeded, we now have a `userCredential` object
      // which contains the newly created `User`.
      User? newUser = userCredential.user;

      // 2. --- Send Verification Email ---
      // It's good practice to check if the user object actually exists before using it.
      if (newUser != null) {
        // We use a separate `try-catch` block specifically for sending the email.
        // This way, even if sending the email fails for some reason (rare),
        // the user account is still created.
        try {
          // This is the Firebase command to send the verification email.
          // Firebase automatically handles creating the link and sending the email.
          await newUser.sendEmailVerification();
          print("Verification email sent successfully!");
        } catch (e) {
          // If sending the email fails, we print an error for our logs,
          // but we don't necessarily need to show it to the user, as their
          // account *was* created. They can try resending later.
          print("ERROR SENDING VERIFICATION EMAIL: $e");
          // Optional: You could return a specific message here if needed.
        }
      }

      // 3. --- Signal Overall Success ---
      // Since the user was created, we return `null` to indicate the sign-up
      // process itself was successful (even if email sending had an issue).
      return null;

    } on FirebaseAuthException catch (e) {
      // --- Handle Sign-Up Errors ---
      // This `catch` block only runs if `createUserWithEmailAndPassword` failed.
      print("FIREBASE ERROR (SIGN UP): ${e.code}");
      // Return the user-friendly error message for the sign-up failure.
      return _getErrorMessage(e.code);
    }
  }

  // --- SIGN OUT ---
  // This function remains the same.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- HELPER FUNCTION: Error Translator ---
  // This function remains the same.
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Wrong email or password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'weak-password':
        return 'Your password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }
    // Inside the AuthService class in auth_service.dart

// --- FORGOT PASSWORD ---
Future<String?> sendPasswordResetEmail(String email) async {
  try {
    // Firebase command to send the reset email.
    await _auth.sendPasswordResetEmail(email: email);
    print("Password reset email sent successfully!");
    return null; // Signal success
  } on FirebaseAuthException catch (e) {
    print("FIREBASE ERROR (Password Reset): ${e.code}");
    // Return a user-friendly message
    if (e.code == 'user-not-found') {
      return 'No user found with this email.';
    } else if (e.code == 'invalid-email') {
      return 'Please enter a valid email address.';
    } else {
      return 'Could not send reset email. Please try again.';
    }
  }
}}