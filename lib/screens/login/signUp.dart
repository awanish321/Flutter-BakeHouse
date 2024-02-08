import 'package:flutter/material.dart';

import 'dart:io';
import 'package:bakery_user_app/screens/home/homeAndroid.dart';
import 'package:bakery_user_app/screens/home/homeIOS.dart';
import 'package:bakery_user_app/widgets/snackbarMessage.dart';
import 'package:bakery_user_app/widgets/button.dart';
import 'package:bakery_user_app/widgets/input_text_field.dart';
import 'package:bakery_user_app/widgets/password_text_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phnController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? deviceToken;

  Future<void> getDeviceToken() async {
    deviceToken = await _firebaseMessaging.getToken();
  }

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
                  controller: nameController,
                  lableText: "Name",
                  hintText: "ex. John",
                  keyBordType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  }),
              InputTextField(
                controller: phnController,
                lableText: "Mobile Number",
                hintText: "9876543210",
                keyBordType: TextInputType.number,
                prefixIcon: const Icon(Icons.phone_android),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 10) {
                    return "Enter valid mobile number";
                  }
                  return null;
                },
              ),
              InputTextField(
                controller: emailController,
                lableText: 'Email Address',
                hintText: 'example@dio.com',
                keyBordType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: (value) => EmailValidator.validate(value!)
                    ? null
                    : 'Please enter valid email',
              ),
              PasswordTextField(
                controller: passwordController,
                hintText: 'example@123',
                lableText: "Password",
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
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text)
                          .then(
                        (value) async {
                          await getDeviceToken();

                          if (deviceToken != null) {
                            FirebaseFirestore.instance.collection('Users').add(
                              {
                                "ImageUrl": "",
                                "Name": nameController.text.trim(),
                                "MobileNumber": phnController.text.trim(),
                                "Email": emailController.text.trim(),
                                "Password": passwordController.text.trim(),
                                "userId":
                                    FirebaseAuth.instance.currentUser!.uid,
                                'DeviceToken': deviceToken,
                              },
                            );
                          }
                        },
                      );

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
                      if (e.code == 'Successful Login') {
                        debugPrint("User successfully signup");

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackbarMessage(
                            iconData: Icons.check_circle_outline,
                            title: 'Success',
                            subtitle: 'User successfully sign-up.',
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            context: context,
                          ),
                        );
                      }
                      if (e.code == 'weak-password') {
                        debugPrint("Use Strong Password");

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackbarMessage(
                            iconData: Icons.error_outline_rounded,
                            title: 'Use strong password',
                            subtitle: 'Please use strong password',
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            context: context,
                          ),
                        );
                      } else if (e.code == 'email-already-in-use') {
                        debugPrint("User Already have an account");

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackbarMessage(
                            iconData: Icons.error_outline_rounded,
                            title: 'Oops. An Error Occured',
                            subtitle:
                                'User already have an account. Please try to log-in.',
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
                  'Sign Up',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
