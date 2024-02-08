import 'dart:io';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/widgets/ads/unity_ads.dart';
import 'package:bakery_user_app/screens/product/productByCategory.dart';
import 'package:bakery_user_app/screens/product/productByDiscount.dart';
import 'package:bakery_user_app/screens/product/productByPrice.dart';
import 'package:bakery_user_app/screens/product/showProducts.dart';
import 'package:bakery_user_app/provider/homeScreenProvider.dart';
import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:bakery_user_app/widgets/shop.dart';
import 'package:bakery_user_app/model/banner.dart';
import 'package:bakery_user_app/model/category.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/cached_image.dart';
import 'package:bakery_user_app/widgets/productWidget.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();

    final homeProvider =
        Provider.of<HomeScreenProvider>(context, listen: false);
    homeProvider.fetchCategoryData();
    homeProvider.fetchBannerData();
    homeProvider.fetchProductData();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await UnityAdManager.loadUnityAd(
            Platform.isIOS ? 'Rewarded_iOS' : 'Rewarded_Android');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenProvider =
        Provider.of<HomeScreenProvider>(context, listen: false);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
            height: Platform.isIOS
                ? MediaQuery.of(context).size.height * 0.13
                : MediaQuery.of(context).size.height * 0.125,
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Category').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display shimmer effect during the waiting state
                  return CategoryShimmer(
                    itemCount: homeScreenProvider.category.length,
                    circleAvatarRadius: 30,
                  );
                } else if (snapshot.hasError) {
                  // Handle error, for example, show an error message
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!.docs;
                homeScreenProvider.category =
                    data.map((e) => CategoryItem.fromJson(e)).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: homeScreenProvider.category.length,
                  itemBuilder: (context, index) {
                    String category =
                        homeScreenProvider.category[index].Category;
                    List<String> categoryWords = category.split(' ');

                    Widget categoryText;

                    if (categoryWords.length == 2) {
                      categoryText = Column(
                        children: [
                          Text(
                            categoryWords[0],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          Text(
                            categoryWords[1],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      );
                    } else {
                      categoryText = Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductByCategory(
                                    category: homeScreenProvider
                                        .category[index].Category,
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  homeScreenProvider.category[index].ImageUrl),
                              radius: 30,
                            ),
                          ),
                          categoryText,
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Banner').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display shimmer effect during the waiting state
                    return const BannerShimmer();
                  } else if (snapshot.hasError) {
                    // Handle error, for example, show an error message
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final data = snapshot.data!.docs;
                  homeScreenProvider.banner =
                      data.map((e) => BannerItem.fromJson(e.data())).toList();

                  return Stack(
                    children: [
                      CarouselSlider.builder(
                        carouselController: _carouselController,
                        itemCount: homeScreenProvider.banner.length,
                        itemBuilder: (context, index, realIndex) {
                          return CachedImage(
                            imageUrl: homeScreenProvider.banner[index].ImageUrl,
                          );
                        },
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            homeScreenProvider.updateActiveIndex(index);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Consumer<HomeScreenProvider>(
                            builder: (context, value, child) {
                              return AnimatedSmoothIndicator(
                                activeIndex: homeScreenProvider.activeIndex,
                                count: homeScreenProvider.banner.length,
                                effect: WormEffect(
                                  dotHeight: 7,
                                  dotWidth: 7,
                                  activeDotColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          UnityBannerAd(
            size: BannerSize.leaderboard,
            placementId: Platform.isIOS ? 'Banner_iOS' : 'Banner_Android',
            onLoad: (placementId) => debugPrint('Banner loaded: $placementId'),
            onClick: (placementId) =>
                debugPrint('Banner clicked: $placementId'),
            onShown: (placementId) => debugPrint('Banner shown: $placementId'),
            onFailed: (placementId, error, message) =>
                debugPrint('Banner Ad $placementId failed: $error $message'),
          ),
          const SizedBox(height: 10),
          Container(
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Just Arrived',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const ShowProductsScreen(),
                            ),
                          );

                          await UnityAdManager.showAds(
                            Platform.isIOS
                                ? 'Rewarded_iOS'
                                : 'Rewarded_Android',
                          );
                        },
                        child: Text(
                          'See all',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .orderBy('Time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Display shimmer effect during the waiting state
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: homeScreenProvider.product.length,
                          itemBuilder: (context, index) {
                            return ProductWidgetShimmer(
                              containerWidth:
                                  MediaQuery.of(context).size.width * 0.5,
                              imageHeight:
                                  MediaQuery.of(context).size.height * 0.2,
                              imageWidth:
                                  MediaQuery.of(context).size.width * 0.5,
                              nameHeight: 20,
                              nameWidth:
                                  MediaQuery.of(context).size.width * 0.5,
                              priceHeight: 20,
                              priceWidth:
                                  MediaQuery.of(context).size.width * 0.3,
                              iconHeight: 20,
                              iconWidth: 25,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        // Handle error, for example, show an error message
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final data = snapshot.data!.docs;
                      homeScreenProvider.product =
                          data.map((e) => ProductItem.fromJson(e)).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: homeScreenProvider.product.length >= 6
                            ? 6
                            : homeScreenProvider.product.length,
                        itemBuilder: (context, index) {
                          return ProductWidget(
                            product: homeScreenProvider.product[index],
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.5,
                            imageHeight:
                                MediaQuery.of(context).size.height * 0.2,
                            imageWidth: MediaQuery.of(context).size.width * 0.5,
                            iconSize: 25,
                            text: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                            first: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            second:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                            third: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
            child: GridSection(
              title: 'Shop by Discount',
              firstImage: 'assets/images/10%Off.png',
              secondImage: 'assets/images/20%Off.png',
              thirdImage: 'assets/images/30%Off.png',
              fourthImage: 'assets/images/40%Off.png',
              first: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByDiscountScreen(discountRange: '0-10%'),
                  ),
                );
              },
              second: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByDiscountScreen(discountRange: '10-20%'),
                  ),
                );
              },
              third: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByDiscountScreen(discountRange: '20-30%'),
                  ),
                );
              },
              fourth: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByDiscountScreen(discountRange: '30-40%'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
            child: GridSection(
              title: 'Shop by Price',
              firstImage: 'assets/images/99.png',
              secondImage: 'assets/images/199.png',
              thirdImage: 'assets/images/299.png',
              fourthImage: 'assets/images/399.png',
              first: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByPriceScreen(priceRange: '0-99'),
                  ),
                );
              },
              second: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByPriceScreen(priceRange: '100-199'),
                  ),
                );
              },
              third: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByPriceScreen(priceRange: '200-299'),
                  ),
                );
              },
              fourth: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProductByPriceScreen(priceRange: '300-399'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
