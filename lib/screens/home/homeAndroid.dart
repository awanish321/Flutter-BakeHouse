import 'package:bakery_user_app/screens/product/search.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakery_user_app/widgets/notificationServices.dart';
import 'package:bakery_user_app/screens/drawerList/cart.dart';
import 'package:bakery_user_app/widgets/mainDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;
import 'package:bakery_user_app/screens/home/homeBody.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeAndroidScreen extends StatefulWidget {
  const HomeAndroidScreen({super.key});

  @override
  State<HomeAndroidScreen> createState() => _HomeAndroidScreenState();
}

class _HomeAndroidScreenState extends State<HomeAndroidScreen> {
  NotificationServices notificationServices = NotificationServices();
  List<CartItem> cartItem = [];
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  var adUnit = "ca-app-pub-3940256099942544/6300978111"; // Testing Ad ID

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
      listener: BannerAdListener(
        onAdClosed: (ad) {
          setState(() {
            isAdLoaded = false;
          });
        },
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Error: $error');
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();

    notificationServices.requestNotificationPermission();
    // notificationServices.isTokenRefresh();
    notificationServices.setupInteractMessage(context);
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken().then(
      (value) {
        debugPrint('Device Token:');
        debugPrint(value);
      },
    );

    initBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('Build');

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
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Wishlist')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection('Cart')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!.docs;
                  cartItem = data.map((e) => CartItem.fromJson(e)).toList();
                } else {
                  return const CircularProgressIndicator();
                }

                return badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -6, end: 3),
                  badgeAnimation: const badges.BadgeAnimation.rotation(
                    animationDuration: Duration(seconds: 1),
                    colorChangeAnimationDuration: Duration(seconds: 1),
                    loopAnimation: false,
                    curve: Curves.fastOutSlowIn,
                    colorChangeAnimationCurve: Curves.easeInCubic,
                  ),
                  badgeContent: Text(
                    cartItem.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const CartScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.shopping_cart,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: const HomeScreenBody(),
      bottomNavigationBar: isAdLoaded
          ? Container(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
              child: AdWidget(ad: bannerAd),
            )
          : const SizedBox(),
    );
  }
}
