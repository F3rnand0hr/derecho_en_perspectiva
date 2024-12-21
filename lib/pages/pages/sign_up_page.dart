// import 'dart:developer';

import 'package:derecho_en_perspectiva/cubits/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up Page'),
          backgroundColor: Colors.redAccent[200],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            const Text('Sign Up'),
            Form(
                key: context.read<LoginCubit>().formKey,
                child: Column(children: [
                  TextFormField(
                    autofocus: true,
                    controller: context.read<LoginCubit>().emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Please enter your Email',
                        hintStyle: const TextStyle(fontSize: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autofocus: true,
                    controller: context.read<LoginCubit>().passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: 'Please enter your Password',
                        hintStyle: const TextStyle(fontSize: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ])),
            BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state){
                if(state.hasError){
                  SnackBar snackBar = SnackBar(content: Text(state.error!));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                }
              },
              builder: (context, state) {
                // log('${state.isLoading}');
                return ElevatedButton(
                    onPressed: () {
                      context.read<LoginCubit>().login();
                    },
                    child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator())
                    : const Text('Sign Up'));
              },
            )
          ]),
        ),
      ),
    );
  }
}
