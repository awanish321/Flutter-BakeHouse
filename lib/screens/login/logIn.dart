import 'package:flutter/material.dart';

import 'dart:io';
import 'package:bakery_user_app/screens/home/homeAndroid.dart';
import 'package:bakery_user_app/screens/home/homeIOS.dart';
import 'package:bakery_user_app/widgets/snackbarMessage.dart';
import 'package:bakery_user_app/screens/login/signUp.dart';
import 'package:bakery_user_app/widgets/button.dart';
import 'package:bakery_user_app/widgets/input_text_field.dart';
import 'package:bakery_user_app/widgets/password_text_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 70),
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .15,
                    child: const Image(
                      image: AssetImage('assets/images/Bakery.png'),
                    ),
                  ),
                ),
              ),
              InputTextField(
                controller: emailController,
                lableText: "Email",
                hintText: "example@dio.com",
                keyBordType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: (value) => EmailValidator.validate(value!)
                    ? null
                    : 'Please enter valid email',
              ),
              PasswordTextField(
                controller: passwordController,
                lableText: 'Password',
                hintText: 'example@123',
                keyBordType: TextInputType.visiblePassword,
                prefixIcon: const Icon(Icons.lock),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 8) {
                    return "Password must be 8 character, enter valid password";
                  }
                  return null;
                },
              ),
              Button(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState!.validate()) {
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text);

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => Platform.isIOS
                              ? const HomeIOSScreen()
                              : const HomeAndroidScreen(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackbarMessage(
                            iconData: Icons.error_outline_rounded,
                            title: 'Oops. An Error Occured',
                            subtitle:
                                'User not found. Please check your username or email address and try again.',
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            context: context,
                          ),
                        );
                      } else if (e.code == 'wrong-password') {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackbarMessage(
                            iconData: Icons.error_outline_rounded,
                            title: 'Oops. An Error Occured',
                            subtitle:
                                'Wrong password. Please check your password and try again',
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            context: context,
                          ),
                        );
                      }
                    }
                  }

                  emailController.clear();
                  passwordController.clear();
                  setState(() {});
                },
                child: Text(
                  'Log In',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
