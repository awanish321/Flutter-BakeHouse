import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:bakery_user_app/widgets/itemWidget.dart';
import 'package:bakery_user_app/widgets/snackbarMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:bakery_user_app/provider/wishlistScreenProvider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();

    final wishlistProvider =
        Provider.of<WishlistScreenProvider>(context, listen: false);
    wishlistProvider.fetchWishlistData();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build');
    final wishlistScreenProvider =
        Provider.of<WishlistScreenProvider>(context, listen: false);

    return Scaffold(
        appBar: ApplicationBar(title: 'Wishlist', context: context),
        body: Consumer<WishlistScreenProvider>(
          builder: (context, value, child) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Wishlist')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection('Wishlist')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display shimmer effect during the waiting state
                  return ItemWidgetShimmer(
                    itemCount: wishlistScreenProvider.wishlist.length,
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
                wishlistScreenProvider.wishlist =
                    data.map((e) => ProductItem.fromJson(e)).toList();

                if (wishlistScreenProvider.wishlist.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "You haven't added any products yet",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Click ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            Text(
                              ' to save products',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          child: Center(
                            child: Text(
                              'Find items to wishlist',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return ListView.builder(
                    itemCount: wishlistScreenProvider.wishlist.length,
                    itemBuilder: (context, index) {
                      return ItemWidget(
                        imageUrl:
                            wishlistScreenProvider.wishlist[index].ImageUrl[0],
                        itemName:
                            wishlistScreenProvider.wishlist[index].Product,
                        itemMRP: wishlistScreenProvider.wishlist[index].MRP,
                        itemPrice: wishlistScreenProvider.wishlist[index].Price,
                        firstContainer: () {
                          try {
                            wishlistScreenProvider.moveItemToCart(
                              wishlistScreenProvider.wishlist[index],
                            );

                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackbarMessage(
                                iconData: Icons.check_circle_outline,
                                title: 'Added to cart',
                                subtitle:
                                    '${wishlistScreenProvider.wishlist[index].Product} is successfully added to your cart.',
                                backgroundColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                context: context,
                              ),
                            );
                          } catch (e) {
                            debugPrint("Error fetching location: $e");
                          }
                        },
                        firstContainerIcon: Icons.shopping_cart_outlined,
                        firstContainerName: 'Move to cart',
                        secondContainer: () async {
                          try {
                            Navigator.of(context).pop();

                            wishlistScreenProvider.removeFromWishlist(
                              wishlistScreenProvider.wishlist[index],
                            );

                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackbarMessage(
                                iconData: Icons.check_circle_outline,
                                title: 'Removed from wishlist',
                                subtitle:
                                    '${wishlistScreenProvider.wishlist[index].Product} is successfully removed from wishlist.',
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                context: context,
                              ),
                            );
                          } catch (e) {
                            debugPrint("Error fetching location: $e");
                          }
                        },
                        includeQuantityDropdown: false,
                      );
                    },
                  );
                }
              },
            );
          },
        ));
  }
}
