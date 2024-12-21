// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:derecho_en_perspectiva/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        centerTitle: true,
      ),
      backgroundColor: Colors.orange[100], // Cream color hex code
      drawer: appDrawer(context),
      body: Center(
        child:
        Image(
            image: AssetImage('assets/law_backround.jpg'),
        ),
      ),
    );
  }
}

