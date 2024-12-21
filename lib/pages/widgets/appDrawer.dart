import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget appDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.orange[200],
    child: Column(
      children: [
        const DrawerHeader(
          child: Icon(
            Icons.account_balance,
            size: 48,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("H O M E"),
          onTap: () {
            context.go('/'); // Navigate to home
          },
        ),
        ListTile(
          leading: const Icon(Icons.album),
          title: const Text('E N T R E V I S T A S'),
          onTap: () {
            context.push('/interviews'); // Replace with the correct path if needed
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text('L O G I N'),
          onTap: () {
            context.pop();
            context.push('/sign-up'); // Navigate to sign-up page
          },
        ),
        ListTile(
            leading: const Icon(Icons.add_chart),
          title: const Text('A R T I C L E S'),
          onTap: (){

          },
        )
      ],
    ),
  );
}
