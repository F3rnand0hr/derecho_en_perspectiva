import 'package:derecho_en_perspectiva/cubits/authCubit.dart';
import 'package:derecho_en_perspectiva/firebase_options.dart';
import 'package:derecho_en_perspectiva/repositories/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  final FirebaseAuthService authService = FirebaseAuthService();

  runApp(
    BlocProvider(
      create: (context) => AuthCubit(authService),
      child: MyApp(),
    ),
  );
}


