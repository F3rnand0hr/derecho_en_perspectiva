import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:derecho_en_perspectiva/repositories/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class AuthCubit extends Cubit<User?> {
  final FirebaseAuthService _authService;

  AuthCubit(this._authService) : super(FirebaseAuth.instance.currentUser) {
    _checkUserStatus();
  }

  void _checkUserStatus() {
    _authService.authStateChanges.listen((user) {
      emit(user); // Emit user whenever auth state changes
    });
  }

  // Handle sign-in
  Future<void> signIn(String email, String password) async {
    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        emit(user); // Emit the signed-in user
      }
    } catch (e) {
      print('Error during sign-in: $e');
      emit(null); // Optionally, handle errors gracefully in the UI
    }
  }

  // Handle sign-up with optional displayName
  Future<void> signUp(String email, String password, {String? displayName}) async {
    try {
      User? user = await _authService.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName); // Set the display name
          await user.reload(); // Reload user to reflect changes
          user = FirebaseAuth.instance.currentUser; // Get updated user
        }
        emit(user); // Emit the signed-up user
      }
    } catch (e) {
      print('Error during sign-up: $e');
      emit(null); // Optionally, handle errors gracefully in the UI
    }
  }

  // Handle logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      emit(null); // Emit null when the user logs out
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
