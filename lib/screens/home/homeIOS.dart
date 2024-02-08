import 'package:bakery_user_app/model/userDetails.dart';
import 'package:bakery_user_app/screens/drawerList/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bakery_user_app/screens/product/search.dart';
import 'package:bakery_user_app/model/banner.dart';
import 'package:bakery_user_app/model/cart.dart';
import 'package:bakery_user_app/model/category.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/screens/drawerList/cart.dart';
import 'package:bakery_user_app/screens/drawerList/settings.dart';
import 'package:bakery_user_app/screens/drawerList/wishlist.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:bakery_user_app/screens/home/homeBody.dart';

class HomeIOSScreen extends StatefulWidget {
  const HomeIOSScreen({super.key});

  @override
  State<HomeIOSScreen> createState() => _HomeIOSScreenState();
}

class _HomeIOSScreenState extends State<HomeIOSScreen> {
  int _selectedIndex = 0;

  List<UserDetails> userDetails = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Home(),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.docs;
          userDetails = data
              .map((e) => UserDetails.fromJson(e))
              .where((element) =>
                  element.userId == FirebaseAuth.instance.currentUser!.uid)
              .toList();

          return ProfileScreen(user: userDetails.first);
        },
      ),
      const WishlistScreen(),
      const CartScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        child: BottomNavigationBar(
          showSelectedLabels: false,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings_solid),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ProductItem> productItem = [];
  List<BannerItem> bannerItem = [];
  List<CategoryItem> categoryItem = [];
  List<CartItem> cartItem = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: TextFormField(
            enabled: false,
            keyboardType: TextInputType.none,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 20,
              ),
              hintText: 'Search Bakery Items',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
      body: const HomeScreenBody(),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Profile', context: context),
    );
  }
}
