import 'dart:io';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/screens/checkout/checkout.dart';
import 'package:bakery_user_app/widgets/itemWidget.dart';
import 'package:bakery_user_app/model/cart.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakery_user_app/widgets/priceContainer.dart';
import 'package:bakery_user_app/widgets/snackbarMessage.dart';
import 'package:bakery_user_app/provider/cartScreenProvider.dart';
import 'package:bakery_user_app/widgets/ads/unity_ads.dart';
import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch cart items when the CartScreen is first initialized.
    final cartProvider =
        Provider.of<CartScreenProvider>(context, listen: false);
    cartProvider.fetchCartData();
    cartProvider.fetchSaveForLaterData();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await UnityAdManager.loadUnityAd(
            Platform.isIOS ? 'Interstitial_iOS' : 'Interstitial_Android');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build');
    final cartScreenProvider =
        Provider.of<CartScreenProvider>(context, listen: false);

    return Scaffold(
      appBar: ApplicationBar(title: 'My Cart', context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<CartScreenProvider>(
              builder: (context, value, child) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Wishlist')
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection('Cart')
                      .orderBy("Time", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display shimmer effect during the waiting state
                      return CartItemShimmer(
                        itemCount: cartScreenProvider.cart.length,
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
                    cartScreenProvider.cart =
                        data.map((e) => CartItem.fromJson(e)).toList();

                    double subtotal = cartScreenProvider
                        .calculateSubtotal(cartScreenProvider.cart);
                    double discount = cartScreenProvider
                        .calculateDiscount(cartScreenProvider.cart);
                    double deliveryCharges =
                        cartScreenProvider.calculateDeliveryCharges(subtotal);
                    double totalAmount =
                        cartScreenProvider.calculateTotalAmount(
                            subtotal, discount, deliveryCharges);

                    return Column(
                      children: [
                        if (cartScreenProvider.cart.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Image.asset(
                                    'assets/images/cartEmpty.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  'Your cart is empty!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        if (cartScreenProvider.cart.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Text(
                                    'Items',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                const Divider(),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartScreenProvider.cart.length,
                                  itemBuilder: (context, index) {
                                    return ItemWidget(
                                      imageUrl: cartScreenProvider
                                          .cart[index].ImageUrl[0],
                                      itemName: cartScreenProvider
                                          .cart[index].Product,
                                      itemMRP:
                                          cartScreenProvider.cart[index].MRP,
                                      itemPrice:
                                          cartScreenProvider.cart[index].Price,
                                      firstContainer: () async {
                                        try {
                                          cartScreenProvider.moveToSaveForLater(
                                            cartScreenProvider.cart[index],
                                          );

                                          if (!context.mounted) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackbarMessage(
                                              iconData:
                                                  Icons.check_circle_outline,
                                              title: 'Moved to save for later',
                                              subtitle:
                                                  '${cartScreenProvider.cart[index].Product} is successfully moved to save for later and removed from cart.',
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                              context: context,
                                            ),
                                          );
                                        } catch (e) {
                                          debugPrint(
                                              "Error saving product: $e");
                                        }

                                        // setState(() {});
                                      },
                                      firstContainerIcon: Icons.save_alt,
                                      firstContainerName: 'Save for later',
                                      secondContainer: () async {
                                        try {
                                          Navigator.of(context).pop();

                                          cartScreenProvider.removeCartItem(
                                            cartScreenProvider.cart[index].id,
                                          );

                                          if (!context.mounted) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackbarMessage(
                                              iconData:
                                                  Icons.check_circle_outline,
                                              title: 'Removed from cart',
                                              subtitle:
                                                  '${cartScreenProvider.cart[index].Product} is successfully removed from cart.',
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .errorContainer,
                                              context: context,
                                            ),
                                          );
                                        } catch (e) {
                                          debugPrint(
                                              "Error saving product: $e");
                                        }

                                        // setState(() {});
                                      },
                                      includeQuantityDropdown: true,
                                      initialSelectedQuantity:
                                          cartScreenProvider
                                              .cart[index].SelecetedQuantity,
                                      cartItemId:
                                          cartScreenProvider.cart[index].id,
                                    );
                                  },
                                ),
                                PriceContainer(
                                  subtotal: subtotal.toStringAsFixed(2),
                                  discount: discount.toStringAsFixed(2),
                                  deliveryCharges:
                                      deliveryCharges.toStringAsFixed(2),
                                  totalAmount: totalAmount.toStringAsFixed(2),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
            Consumer<CartScreenProvider>(
              builder: (context, value, child) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Wishlist')
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection('SaveForLater')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display shimmer effect during the waiting state
                      return SaveForLaterItemShimmer(
                          itemCount: cartScreenProvider.saveForLater.length);
                    } else if (snapshot.hasError) {
                      // Handle error, for example, show an error message
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data = snapshot.data!.docs;
                    cartScreenProvider.saveForLater =
                        data.map((e) => CartItem.fromJson(e)).toList();

                    if (cartScreenProvider.saveForLater.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Text(
                                cartScreenProvider.saveForLater.isNotEmpty
                                    ? 'Saved for later'
                                    : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const Divider(),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartScreenProvider.saveForLater.length,
                              itemBuilder: (context, index) {
                                return ItemWidget(
                                  imageUrl: cartScreenProvider
                                      .saveForLater[index].ImageUrl[0],
                                  itemName: cartScreenProvider
                                      .saveForLater[index].Product,
                                  itemMRP: cartScreenProvider
                                      .saveForLater[index].MRP,
                                  itemPrice: cartScreenProvider
                                      .saveForLater[index].Price,
                                  firstContainer: () async {
                                    try {
                                      cartScreenProvider.moveItemToCart(
                                        cartScreenProvider.saveForLater[index],
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackbarMessage(
                                          iconData: Icons.check_circle_outline,
                                          title: 'Moved to cart',
                                          subtitle:
                                              '${cartScreenProvider.saveForLater[index].Product} is successfully moved to cart.',
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          context: context,
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint("Error fetching location: $e");
                                    }

                                    // setState(() {});
                                  },
                                  firstContainerIcon:
                                      Icons.shopping_cart_outlined,
                                  firstContainerName: 'Move to cart',
                                  secondContainer: () async {
                                    try {
                                      Navigator.of(context).pop();

                                      cartScreenProvider.removeFromSaveForLater(
                                        cartScreenProvider.saveForLater[index],
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackbarMessage(
                                          iconData: Icons.check_circle_outline,
                                          title: 'Removed from save for later',
                                          subtitle:
                                              '${cartScreenProvider.saveForLater[index].Product} is successfully removed from save for later.',
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .errorContainer,
                                          context: context,
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint("Error fetching location: $e");
                                    }

                                    // setState(() {});
                                  },
                                  includeQuantityDropdown: false,
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      );
                    } else {
                      return const Row();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Wishlist')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('Cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.docs;
          cartScreenProvider.cart =
              data.map((e) => CartItem.fromJson(e)).toList();

          double subtotal =
              cartScreenProvider.calculateSubtotal(cartScreenProvider.cart);
          double discount =
              cartScreenProvider.calculateDiscount(cartScreenProvider.cart);
          double deliveryCharges =
              cartScreenProvider.calculateDeliveryCharges(subtotal);
          double totalAmount = cartScreenProvider.calculateTotalAmount(
              subtotal, discount, deliveryCharges);

          return cartScreenProvider.cart.isNotEmpty
              ? BottomAppBar(
                  color: Theme.of(context).colorScheme.onSecondary,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹${subtotal.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '₹${totalAmount.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(
                                  source: "Cart",
                                ),
                              ),
                            );

                            await UnityAdManager.showAds(
                              Platform.isIOS
                                  ? 'Interstitial_iOS'
                                  : 'Interstitial_Android',
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Center(
                              child: Text(
                                'Place Order',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Row();
        },
      ),
    );
  }
}
