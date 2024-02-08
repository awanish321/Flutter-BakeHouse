import 'package:bakery_user_app/model/order.dart';
import 'package:bakery_user_app/screens/checkout/orderDetails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/widgets/appBar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderItem> order = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Orders', context: context),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Wishlist')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('Orders')
            .orderBy('Time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.docs;
          order = data.map((e) => OrderItem.fromJson(e)).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: order.length,
            itemBuilder: (context, index1) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                        orderItem: order[index1],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary
                      .withOpacity(0.4),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.width * 0.3,
                          fit: BoxFit.cover,
                          imageUrl: order[index1].Items.first.ImageUrl,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Image(
                                image: AssetImage('assets/images/loading.gif'),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Orders')
                                    .doc(order[index1].id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final orderAdminData = snapshot.data!.data();
                                  if (orderAdminData != null) {
                                    final orderStatus =
                                        orderAdminData['OrderStatus'] as String;

                                    return Text(
                                      orderStatus,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.5),
                                          ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Text(
                                order[index1]
                                    .Items
                                    .map((item) => item.Product)
                                    .join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                orderItem: order[index1],
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
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
