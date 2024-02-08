import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:bakery_user_app/widgets/productWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductByPriceScreen extends StatefulWidget {
  const ProductByPriceScreen({super.key, required this.priceRange});

  final String priceRange;

  @override
  State<ProductByPriceScreen> createState() => _ProductByPriceScreenState();
}

class _ProductByPriceScreenState extends State<ProductByPriceScreen> {
  List<ProductItem> productsInPriceRange = [];

  String calculatePriceRange(String price) {
    double priceValue = double.tryParse(price) ?? 0;

    if (priceValue >= 0 && priceValue <= 99) {
      return '0-99';
    } else if (priceValue > 100 && priceValue <= 199) {
      return '100-199';
    } else if (priceValue > 200 && priceValue <= 299) {
      return '200-299';
    } else if (priceValue > 300 && priceValue <= 399) {
      return '300-399';
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
              itemCount: productsInPriceRange.length,
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
          productsInPriceRange =
              data.map((e) => ProductItem.fromJson(e)).where((product) {
            final range = calculatePriceRange(product.Price);
            return range == widget.priceRange;
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: productsInPriceRange.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ProductWidget(
                  product: productsInPriceRange[index],
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
