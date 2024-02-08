import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:bakery_user_app/widgets/productWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class ProductByCategory extends StatefulWidget {
  ProductByCategory({super.key, required this.category});

  String category;

  @override
  State<ProductByCategory> createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> {
  List<ProductItem> product = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(
        title: widget.category,
        context: context,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Product').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display shimmer effect during the waiting state
            return ListView.builder(
              shrinkWrap: true,
              itemCount: product.length,
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
          product = data
              .map((e) => ProductItem.fromJson(e))
              .where((element) => element.Category.toLowerCase()
                  .contains(widget.category.toLowerCase()))
              .toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: product.length >= 6 ? 6 : product.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ProductWidget(
                  product: product[index],
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
