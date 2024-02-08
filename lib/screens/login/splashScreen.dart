import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:io';
import 'dart:async';
import 'package:bakery_user_app/screens/home/homeAndroid.dart';
import 'package:bakery_user_app/screens/home/homeIOS.dart';
import 'package:bakery_user_app/screens/login/logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection
        showNoInternetAlertDialog();
      } else {
        if (FirebaseAuth.instance.currentUser != null) {
          if (!context.mounted) {
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => Platform.isIOS
                  ? const HomeIOSScreen()
                  : const HomeAndroidScreen(),
            ),
          );
        } else {
          if (!context.mounted) {
            return;
          }

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const LogInScreen()));
        }
      }
    });
  }

  void showNoInternetAlertDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: Text(
              'You are not connected to the internet.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Close the app when the user clicks the Exit button
                  SystemNavigator.pop();
                },
                child: Text(
                  'Exit',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: Text(
              'You are not connected to the internet.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Close the app when the user clicks the Exit button
                  SystemNavigator.pop();
                },
                child: Text(
                  'Exit',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(
        height: MediaQuery.of(context).size.height * 0.2,
        image: const AssetImage('assets/images/Bakery.png'),
      ),
    );
  }
}
