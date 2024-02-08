import 'package:flutter/material.dart';

import 'package:bakery_user_app/screens/product/productDetails.dart';
import 'package:bakery_user_app/widgets/price.dart';
import 'package:bakery_user_app/widgets/snackbarMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakery_user_app/widgets/cached_image.dart';
import 'package:bakery_user_app/model/product.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
    required this.product,
    required this.containerWidth,
    required this.imageHeight,
    required this.imageWidth,
    required this.text,
    required this.first,
    required this.second,
    required this.third,
    required this.iconSize,
  });

  final ProductItem product;
  final double containerWidth;
  final double imageHeight;
  final double imageWidth;
  final double iconSize;
  final TextStyle text;
  final TextStyle first;
  final TextStyle second;
  final TextStyle third;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  void _addToWishlist() async {
    await FirebaseFirestore.instance
        .collection('Wishlist')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('Wishlist')
        .doc(widget.product.id)
        .set(widget.product.toJson());
  }

  String calculateDiscountPercentage(String mrp, String price) {
    double mrpValue = double.tryParse(mrp) ?? 0;
    double priceValue = double.tryParse(price) ?? 0;

    if (mrpValue <= 0 || priceValue <= 0) {
      return '0';
    }

    double discountPercentage =
        ((mrpValue - priceValue) / mrpValue * 100).roundToDouble();
    return discountPercentage.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsScreen(productItem: widget.product),
          ),
        );
      },
      child: Container(
        width: widget.containerWidth,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 0.3,
          ),
        ),
        child: Card(
          margin: const EdgeInsets.all(8),
          shape: const BeveledRectangleBorder(),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: widget.imageHeight,
                width: widget.imageWidth,
                child: CachedImage(
                  imageUrl: widget.product.ImageUrl[0],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.product.Product,
                overflow: TextOverflow.ellipsis,
                style: widget.text,
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriceShow(
                    MRP: widget.product.MRP,
                    Price: widget.product.Price,
                    first: widget.first,
                    second: widget.second,
                    third: widget.third,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Wishlist')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('Wishlist')
                        .doc(widget.product.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        bool isWishlist = snapshot.data!.exists;

                        return InkWell(
                          onTap: () async {
                            if (!isWishlist) {
                              _addToWishlist();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackbarMessage(
                                  iconData: Icons.check_circle_outline,
                                  title: 'Added to wishlist',
                                  subtitle:
                                      '${widget.product.Product} is successfully added to wishlist.',
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  context: context,
                                ),
                              );
                            } else {
                              await FirebaseFirestore.instance
                                  .collection("Wishlist")
                                  .doc(FirebaseAuth.instance.currentUser!.email)
                                  .collection("Wishlist")
                                  .doc(widget.product.id)
                                  .delete();

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackbarMessage(
                                  iconData: Icons.check_circle_outline,
                                  title: 'Removed from wishlist',
                                  subtitle:
                                      '${widget.product.Product} is successfully removed from wishlist.',
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                  context: context,
                                ),
                              );
                            }
                          },
                          child: isWishlist
                              ? Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: widget.iconSize,
                                )
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  size: widget.iconSize,
                                ),
                        );
                      }
                      return const Row();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
