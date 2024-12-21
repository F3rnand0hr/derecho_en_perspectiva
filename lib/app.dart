import 'package:derecho_en_perspectiva/cubits/cubit/login_cubit.dart';
import 'package:derecho_en_perspectiva/pages/pages/home_page.dart';
import 'package:derecho_en_perspectiva/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/pages/pages/sign_up_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.red[800]),
        routerConfig: router,
      ),
    );
  }
}