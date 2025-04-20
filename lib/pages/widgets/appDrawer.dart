import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart'; // Ensure AuthCubit is imported

Widget appDrawer(BuildContext context) {
  final user = context.watch<AuthCubit>().state; // Get auth state

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
            context.push('/interviews'); // Navigate to interviews
          },
        ),

        ListTile(
          leading: const Icon(
            Icons.pageview,
            color: AppColors.coffee,
          ),
          title: const Text('R E V I S T A S'),
          onTap: (){
            context.push('/magazinePage'); // Navigate to magazines
          },
        ),

        user == null
            ? ListTile(
                leading: const Icon(
                  Icons.account_circle,
                  color: AppColors.coffee,
                ),
                title: const Text('C R E A R  C U E N T A'),
                onTap: () {
                  context.pop();
                  context.push('/sign-up'); // Navigate to sign-up page
                },
              )

            : ListTile(
                leading: const Icon(
                  Icons.person,
                  color: AppColors.coffee,
                ),
                title: const Text('M I  C U E N T A'),
                onTap: () {
                  context.pop();
                  context.push('/userPage'); // Navigate to user dashboard
                },
              ),
        if(user == null )
          ListTile(
            leading: const Icon(
              Icons.login,
              color: AppColors.coffee,
            ),
            title: const Text('I N I C I A R  S E S I O N'),
            onTap: (){
              context.pop();
              context.push('/logInPage');
            },
          ),
        ListTile(
          leading: const Icon(
            Icons.add_chart,
            color: AppColors.coffee,
          ),
          title: const Text('A R T I C L E S'),
          onTap: () {
            context.pop();
            context.push('/articles');
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.add_business_rounded,
            color: AppColors.coffee,
          ),
          title: const Text('C O N T Á C T E N O S'),
          onTap: () {},
        ),
        if (user != null) // Show logout option if user is logged in
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text('C E R R A R  S E S I Ó N'),
            onTap: () {
              context.read<AuthCubit>().logout();
              context.pop();
              context.go('/'); // Redirect to home after logout
            },
          ),
      ],
    ),
  );
}
