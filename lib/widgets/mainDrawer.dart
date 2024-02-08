import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bakery_user_app/screens/drawerList/cart.dart';
import 'package:bakery_user_app/screens/drawerList/orders.dart';
import 'package:bakery_user_app/screens/drawerList/settings.dart';
import 'package:bakery_user_app/screens/drawerList/wishlist.dart';
import 'package:bakery_user_app/model/userDetails.dart';
import 'package:bakery_user_app/screens/drawerList/profile.dart';
import 'package:bakery_user_app/screens/login/logIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakery_user_app/screens/home/homeAndroid.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  List<UserDetails> userDetails = [];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cake.png'),
                opacity: 0.2,
                fit: BoxFit.fill,
              ),
            ),
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display shimmer effect during the waiting state
                  return const DrawerHeaderShimmer();
                } else if (snapshot.hasError) {
                  // Handle error, for example, show an error message
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!.docs;
                userDetails = data
                    .map((e) => UserDetails.fromJson(e))
                    .where((element) =>
                        element.userId ==
                        FirebaseAuth.instance.currentUser!.uid)
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: userDetails.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        userDetails[index].ImageUrl != ''
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userDetails[index].ImageUrl),
                                radius: 35,
                              )
                            : const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/per.png'),
                                radius: 35,
                              ),
                        Text(
                          userDetails[index].Name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          userDetails[index].Email,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Home',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const HomeAndroidScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              size: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ProfileScreen(
                    user: userDetails.first,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite_outline,
              size: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Wishlist',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const WishlistScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.shopping_cart_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Cart',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const CartScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.cube_box,
              size: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Orders',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const OrdersScreen(),
                ),
              );
            },
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Log Out',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (ctx) => const LogInScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
