import 'package:flutter/material.dart';

import 'dart:io';
import 'package:bakery_user_app/screens/product/review_rating.dart';
import 'package:bakery_user_app/screens/checkout/checkout.dart';
import 'package:bakery_user_app/model/cart.dart';
import 'package:bakery_user_app/widgets/price.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/model/rating.dart';
import 'package:bakery_user_app/screens/drawerList/cart.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:bakery_user_app/widgets/cached_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:bakery_user_app/widgets/snackbarMessage.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget {
  ProductDetailsScreen({super.key, required this.productItem});

  ProductItem productItem;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int activeIndex = 0;
  List<RatingItem> ratingItem = [];
  List<CartItem> cartItem = [];
  int _selectedQuantity = 1;
  List<int> quantityOptions = [1, 2, 3, 4, 5];
  late InterstitialAd interstitialAd;
  bool isAdLoaded = false;
  var adUnit = "ca-app-pub-3940256099942544/1033173712";

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          setState(() {
            isAdLoaded = true;
          });
          interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                isAdLoaded = false;
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              print('Error: $error');
            },
          );
        },
        onAdFailedToLoad: (error) {
          interstitialAd.dispose();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initInterstitialAd();
  }

  double calculateAverageRating(List<RatingItem> ratings) {
    if (ratings.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;

    for (var rating in ratings) {
      setState(() {
        totalRating += double.tryParse(rating.Rating) ?? 0.0;
      });
    }

    return totalRating / ratings.length;
  }

  void _addToCart() async {
    try {
      Map<String, dynamic> cartItemData = {
        "Time": FieldValue.serverTimestamp(),
        'SelectedQuantity': _selectedQuantity.toString(),
        ...widget.productItem.toJson(),
      };

      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Cart')
          .doc(widget.productItem.id)
          .set(cartItemData);
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  void _addToWishlist() async {
    try {
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Wishlist')
          .doc(widget.productItem.id)
          .set(widget.productItem.toJson());
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String nutritionString =
        widget.productItem.Nutritions.nutritions.toString();
    List<String> keyValuePairs = nutritionString
        .replaceAll('[', '') // Remove '['
        .replaceAll(']', '') // Remove ']'
        .split(',') // Split by ','
        .map((pair) => pair.trim()) // Remove leading/trailing spaces
        .toList();

    return Scaffold(
      appBar: ApplicationBar(
        title: 'Item Detail',
        context: context,
        actions: [
          StreamBuilder(
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
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CarouselSlider.builder(
                    itemCount: widget.productItem.ImageUrl.length,
                    itemBuilder: (context, index, realIndex) {
                      return CachedImage(
                          imageUrl: widget.productItem.ImageUrl[index]);
                    },
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.45,
                      onPageChanged: (index, reason) {
                        setState(() {
                          activeIndex = index;
                        });
                      },
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      autoPlayAnimationDuration: const Duration(seconds: 3),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Wishlist')
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection('Wishlist')
                      .doc(widget.productItem.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      bool isWishlist = snapshot.data!.exists;

                      return Positioned(
                        top: MediaQuery.of(context).size.height * 0.025,
                        left: MediaQuery.of(context).size.width * .85,
                        bottom: MediaQuery.of(context).size.height * .39,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Theme.of(context).colorScheme.onSecondary),
                          child: IconButton(
                            onPressed: () async {
                              if (!isWishlist) {
                                _addToWishlist();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackbarMessage(
                                    iconData: Icons.check_circle_outline,
                                    title: 'Added to wishlist',
                                    subtitle:
                                        '${widget.productItem.Product} is successfully added to wishlist.',
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    context: context,
                                  ),
                                );
                              } else {
                                await FirebaseFirestore.instance
                                    .collection("Wishlist")
                                    .doc(FirebaseAuth
                                        .instance.currentUser!.email)
                                    .collection("Wishlist")
                                    .doc(widget.productItem.id)
                                    .delete();

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackbarMessage(
                                    iconData: Icons.check_circle_outline,
                                    title: 'Removed from wishlist',
                                    subtitle:
                                        '${widget.productItem.Product} is successfully removed from wishlist.',
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                    context: context,
                                  ),
                                );
                              }
                            },
                            icon: isWishlist
                                ? const Icon(
                                    Icons.favorite,
                                    size: 30,
                                    color: Colors.red,
                                  )
                                : Icon(
                                    Icons.favorite_border_rounded,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                          ),
                        ),
                      );
                    }
                    return const Row();
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.085,
                  left: MediaQuery.of(context).size.width * .85,
                  bottom: MediaQuery.of(context).size.height * .33,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final text =
                            "Check out this product: ${widget.productItem.Product} - Price: ${widget.productItem.Price}";
                        final imageUri = Uri.parse(
                          widget.productItem.ImageUrl[0],
                        );
                        final res = await http.get(imageUri);
                        final bytes = res.bodyBytes;
                        final temp = await getTemporaryDirectory();
                        final path = '${temp.path}/image.png';
                        File(path).writeAsBytesSync(bytes);

                        // ignore: deprecated_member_use
                        await Share.shareFiles([path], text: text);
                      },
                      icon: Icon(
                        Icons.share,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: widget.productItem.ImageUrl.length,
                effect: WormEffect(
                  dotHeight: 5,
                  dotWidth: 5,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.productItem.Product,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            RatingBarIndicator(
              rating: calculateAverageRating(ratingItem),
              itemCount: 5,
              itemSize: 25,
              itemBuilder: (context, index) {
                return const Icon(
                  Icons.star,
                  color: Colors.amber,
                );
              },
            ),
            PriceShow(
              MRP: widget.productItem.MRP,
              Price: widget.productItem.Price,
              first: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              second: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                  ),
              third: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Quntity: ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton(
                    dropdownColor: Theme.of(context).colorScheme.onSecondary,
                    value: _selectedQuantity,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedQuantity = newValue!;
                      });
                    },
                    items: quantityOptions.map((quantity) {
                      return DropdownMenuItem(
                        value: quantity,
                        child: Text(
                          '$quantity',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Text(
                'About this product:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                widget.productItem.Description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Text(
                'Ingredients:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                widget.productItem.Ingredients,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Text(
                'Nutritions:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Column(
                  children: keyValuePairs.map((value) {
                    List<String> parts = value.split(':');
                    if (parts.length == 2) {
                      String nutrition = parts[0];
                      String weight = parts[1];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 20, 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              nutrition,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                            Text(
                              weight,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      );
                    }
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Weight:',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.productItem.Weight,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Text(
                    'Ratings and Reviews:',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              RatingScreen(productItem: widget.productItem),
                        ),
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * .05,
                      width: MediaQuery.of(context).size.width * .3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: .3,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Rate Product',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Product')
                  .doc(widget.productItem.id)
                  .collection('Rating')
                  .orderBy('Time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!.docs;
                ratingItem = data.map((e) => RatingItem.fromJson(e)).toList();

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ratingItem.length,
                  itemBuilder: (context, index) {
                    String value = ratingItem[index].Rating;
                    double rating = double.parse(value);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ratingItem[index].Image.isEmpty
                                  ? const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/per.png'),
                                      radius: 20,
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        ratingItem[index].Image,
                                      ),
                                      radius: 20,
                                    ),
                              const SizedBox(width: 10),
                              Text(
                                ratingItem[index].Name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          RatingBarIndicator(
                            itemCount: 5,
                            rating: rating,
                            itemSize: 20,
                            itemBuilder: (context, index) {
                              return const Icon(
                                Icons.star,
                                color: Colors.amber,
                              );
                            },
                          ),
                          Text(
                            ratingItem[index].Review,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          Text(
                            'Admin: ${ratingItem[index].Reply}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Wishlist')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection('Cart')
                .doc(widget.productItem.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool isInCart = snapshot.data!.exists;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!isInCart) {
                        _addToCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackbarMessage(
                            context: context,
                            backgroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                            iconData: Icons.check_circle_outline,
                            title: 'Added to cart',
                            subtitle:
                                '${widget.productItem.Product} is successfully added to your cart.',
                          ),
                        );

                        if (isAdLoaded) {
                          interstitialAd.show();
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Center(
                        child: Text(
                          isInCart ? 'Go to Cart' : 'Add to Cart',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const Row();
            },
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                _addToCart();

                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(
                      source: "ProductDetails",
                    ),
                  ),
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Center(
                  child: Text(
                    'Buy Now',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
