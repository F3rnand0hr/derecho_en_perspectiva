import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';

Widget appDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: AppColors.tan,
    child: Column(
      children: [
        const DrawerHeader(
          child: Icon(
            Icons.account_balance,
            color: AppColors.coffee,
            size: 48,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.home,
            color: AppColors.coffee,
            ),
          title: const Text("H O M E"),
          onTap: () {
            context.go('/'); // Navigate to home
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.album,
            color: AppColors.coffee,
            ),
          title: const Text('E N T R E V I S T A S'),
          onTap: () {
            context.push('/interviews'); // Replace with the correct path if needed
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.account_circle,
            color: AppColors.coffee,
            ),
          title: const Text('C R E A R  C U E N T A'),
          onTap: () {
            context.pop();
            context.push('/sign-up'); // Navigate to sign-up page
          },
        ),
        ListTile(
            leading: const Icon(
                color: AppColors.coffee,
                Icons.add_chart),
          title: const Text('A R T I C L E S'),
          onTap: (){
            context.pop();
            context.push('/articles');
          },
        ),

        // About Us
        ListTile(
          leading: const Icon(
            color: AppColors.coffee,
            Icons.add_business_rounded),
         title: const Text('C O N T Á C T E N O S'),
         onTap: (){
         },
        )
      ],
    ),
  );
}
