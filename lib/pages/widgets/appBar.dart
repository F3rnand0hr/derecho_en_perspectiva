import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

PreferredSizeWidget appBar(BuildContext context, ) {
  final user = context.read<User?>(); // Assuming you have a User model
  return PreferredSize(
    preferredSize: const Size.fromHeight(80.0),
    child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // Remove shadow
          iconTheme: IconThemeData(
            color: const Color.fromARGB(255, 168, 167, 167),
            size: 50
            ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                if (user != null){
                  context.push('/userPage');
                }
                else{
                  context.push('/sign-up');
                }
              },
            ),
          ],
          title: Image.asset(
            'assets/photos/pre-law-logo.png',
            height: 60,
            width: 60,
            ),
        ),
  );
}