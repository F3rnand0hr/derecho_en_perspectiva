import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:derecho_en_perspectiva/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class AuthCubit extends Cubit<User?> {
  final FirebaseAuthService _authService;

  AuthCubit(this._authService) : super(null) {
    _checkUserStatus();
  }

  // Check and listen for auth state changes
  void _checkUserStatus() {
    _authService.authStateChanges.listen((user) {
      emit(user);
    });
  }

  // Handle sign-in
  Future<void> signIn(String email, String password) async {
    User? user = await _authService.signInWithEmailAndPassword(email, password);
    if (user != null) {
      emit(user);
    }
  }

  // Handle sign-up
  Future<void> signUp(String email, String password) async {
    User? user = await _authService.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      emit(user);
    }
  }

  // Handle logout
  Future<void> logout() async {
    await _authService.signOut();
    emit(null);
  }
}
