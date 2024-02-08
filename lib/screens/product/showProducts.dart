import 'package:flutter/material.dart';

import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:bakery_user_app/widgets/productWidget.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowProductsScreen extends StatefulWidget {
  const ShowProductsScreen({super.key});

  @override
  State<ShowProductsScreen> createState() => _ShowProductsScreenState();
}

class _ShowProductsScreenState extends State<ShowProductsScreen> {
  List<ProductItem> productItem = [];
  bool isWishlist = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: Text(
          'Products',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Product")
            .orderBy('Time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display shimmer effect during the waiting state
            return ListView.builder(
              shrinkWrap: true,
              itemCount: productItem.length,
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
          // print("Json Decode Data" + jsonEncode(data[0].data()));
          productItem = data.map((e) => ProductItem.fromJson(e)).toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: productItem.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ProductWidget(
                  product: productItem[index],
                  containerWidth: MediaQuery.of(context).size.width,
                  imageHeight: MediaQuery.of(context).size.height * 0.25,
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
