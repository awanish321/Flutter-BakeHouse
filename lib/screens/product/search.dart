import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/productWidget.dart';
import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late FocusNode _focusNode;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<ProductItem> productItem = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    searchController.addListener(_onSearchInputChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchInputChange() {
    final newQuery = searchController.text;
    if (query != newQuery) {
      setState(() {
        query = newQuery;
        isSearching = newQuery.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: TextFormField(
          focusNode: _focusNode,
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSecondary,
              size: 20,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    onPressed: () {
                      searchController.clear();
                    },
                  )
                : null,
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
      body: isSearching
          ? StreamBuilder(
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
                          imageHeight:
                              MediaQuery.of(context).size.height * 0.25,
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
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No search results found.",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  );
                }

                final data = snapshot.data!.docs;
                // print("Json Decode Data" + jsonEncode(data[0].data()));
                productItem = data.map((e) => ProductItem.fromJson(e)).toList();

                if (query.isNotEmpty) {
                  productItem = productItem.where((element) {
                    final lowerCaseQuery = query.toLowerCase();
                    return element.Product.toLowerCase()
                            .contains(lowerCaseQuery) ||
                        element.Category.toLowerCase()
                            .contains(lowerCaseQuery) ||
                        element.SubCategory.toLowerCase()
                            .contains(lowerCaseQuery);
                  }).toList();
                }

                if (productItem.isEmpty) {
                  return Center(
                    child: Text(
                      "No search results found.",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  );
                }

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
                        imageHeight: MediaQuery.of(context).size.height * 0.26,
                        imageWidth: MediaQuery.of(context).size.width,
                        iconSize: 30,
                        text: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                        first:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                        second:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
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
            )
          : Center(
              child: Text(
                "Start typing to search for bakery items.",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
    );
  }
}
