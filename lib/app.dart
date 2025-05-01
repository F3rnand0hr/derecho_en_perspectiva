import 'package:derecho_en_perspectiva/routes/routes.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.red[800]),
        routerConfig: router,
      );
  }
}