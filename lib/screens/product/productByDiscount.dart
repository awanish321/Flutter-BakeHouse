import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:bakery_user_app/widgets/productWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductByDiscountScreen extends StatefulWidget {
  const ProductByDiscountScreen({super.key, required this.discountRange});

  final String discountRange;

  @override
  State<ProductByDiscountScreen> createState() =>
      _ProductByDiscountScreenState();
}

class _ProductByDiscountScreenState extends State<ProductByDiscountScreen> {
  List<ProductItem> productsWithDiscount = [];

  String calculateDiscountRange(String mrp, String price) {
    double mrpValue = double.tryParse(mrp) ?? 0;
    double priceValue = double.tryParse(price) ?? 0;

    if (mrpValue <= 0 || priceValue <= 0) {
      return '0-10%';
    }

    double discountPercentage =
        ((mrpValue - priceValue) / mrpValue * 100).roundToDouble();

    if (discountPercentage >= 0 && discountPercentage <= 10) {
      return '0-10%';
    } else if (discountPercentage > 10 && discountPercentage <= 20) {
      return '10-20%';
    } else if (discountPercentage > 20 && discountPercentage <= 30) {
      return '20-30%';
    } else if (discountPercentage > 30 && discountPercentage <= 40) {
      return '30-40%';
    }

    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Products', context: context),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Product').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display shimmer effect during the waiting state
            return ListView.builder(
              shrinkWrap: true,
              itemCount: productsWithDiscount.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ProductWidgetShimmer(
                    containerWidth: MediaQuery.of(context).size.width,
                    imageHeight: MediaQuery.of(context).size.height * 0.25,
                    imageWidth: MediaQuery.of(context).size.width,
                    nameHeight: 25,
                    nameWidth: MediaQuery.of(context).size.width,
                    priceHeight: 25,
                    priceWidth: MediaQuery.of(context).size.width * 0.5,
                    iconHeight: 25,
                    iconWidth: 25,
                  ),
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
          productsWithDiscount =
              data.map((e) => ProductItem.fromJson(e)).where((product) {
            final range = calculateDiscountRange(product.MRP, product.Price);
            return range == widget.discountRange;
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: productsWithDiscount.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ProductWidget(
                  product: productsWithDiscount[index],
                  containerWidth: MediaQuery.of(context).size.width,
                  imageHeight: MediaQuery.of(context).size.height * 0.26,
                  imageWidth: MediaQuery.of(context).size.width,
                  iconSize: 30,
                  text: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                  first: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                  second: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                      ),
                  third: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
