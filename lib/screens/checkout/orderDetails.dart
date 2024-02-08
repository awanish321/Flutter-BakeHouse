import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bakery_user_app/model/order.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderItem});

  final OrderItem orderItem;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  int currentStep = 0;

  StepState getOrderState(
      String orderStatus, String targetStatus, int stepIndex) {
    if (stepIndex <= currentStep) {
      return StepState.complete;
    } else if (orderStatus == targetStatus) {
      return StepState.complete;
    } else {
      return StepState.indexed;
    }
  }

  int _calculateCurrentStep(String orderStatus) {
    if (orderStatus == "Order Delivered") {
      return 4; // Set the current step to the last step
    } else if (orderStatus == "Out For Delivery") {
      return 3; // Set the current step to the appropriate step
    } else if (orderStatus == "Order Shipped") {
      return 2;
    } else if (orderStatus == "Order Confirmed") {
      return 1;
    } else {
      return 0; // Default to the first step
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Order Details', context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      'Order ID - #${widget.orderItem.OrderId}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ),
                    ),
                  ),
                  const Divider(),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.orderItem.Items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height * 0.12,
                              width: MediaQuery.of(context).size.width * 0.3,
                              imageUrl: widget.orderItem.Items[index].ImageUrl,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Image(
                                    image:
                                        AssetImage('assets/images/loading.gif'),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 3, 8, 0),
                                  child: Text(
                                    widget.orderItem.Items[index].Product,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Text(
                                    '₹${widget.orderItem.Items[index].Price}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Qty: ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                      Text(
                                        widget.orderItem.Items[index]
                                            .SelecetedQuantity,
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
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Center(
                            child: Text(
                              'Cancle',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 0.5,
                        height: 30,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Center(
                            child: Text(
                              'Need help?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      'Order status',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ),
                    ),
                  ),
                  const Divider(),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Orders')
                        .doc(widget.orderItem.id)
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

                        currentStep = _calculateCurrentStep(orderStatus);

                        return Stepper(
                          physics: const NeverScrollableScrollPhysics(),
                          controlsBuilder: (context, details) {
                            return Container();
                          },
                          steps: [
                            Step(
                              title: Text(
                                "Order Placed",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                              subtitle: Text(
                                "Your order has been placed.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                    ),
                              ),
                              isActive: currentStep >= 0,
                              state:
                                  getOrderState(orderStatus, "Order Placed", 0),
                              content: const SizedBox.shrink(),
                            ),
                            Step(
                              title: Text(
                                "Order Confirmed",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                              subtitle: Text(
                                "Your order has been confirmed.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                    ),
                              ),
                              isActive: currentStep >= 1,
                              state: getOrderState(
                                  orderStatus, "Order Confirmed", 1),
                              content: const SizedBox.shrink(),
                            ),
                            Step(
                              title: Text(
                                "Order Shipped",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                              subtitle: Text(
                                "Your order has been shipped.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                    ),
                              ),
                              isActive: currentStep >= 2,
                              state: getOrderState(
                                  orderStatus, "Order Shipped", 2),
                              content: const SizedBox.shrink(),
                            ),
                            Step(
                              title: Text(
                                "Out For Delivery",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                              subtitle: Text(
                                "Your order is out for delivery.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                    ),
                              ),
                              isActive: currentStep >= 3,
                              state: getOrderState(
                                  orderStatus, "Out For Delivery", 3),
                              content: const SizedBox.shrink(),
                            ),
                            Step(
                              title: Text(
                                "Order Delivered",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                              subtitle: Text(
                                "Your order has been delivered.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                    ),
                              ),
                              isActive: currentStep >= 4,
                              state: getOrderState(
                                  orderStatus, "Order Delivered", 4),
                              content: const SizedBox.shrink(),
                            ),
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      'Shipping address',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      widget.orderItem.UserName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      widget.orderItem.Address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      widget.orderItem.UserPhoneNumber,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      'Payment method',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Text(
                      '${widget.orderItem.PaymentMethod}:  ₹${widget.orderItem.Amount}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
