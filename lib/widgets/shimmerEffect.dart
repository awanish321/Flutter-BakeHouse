import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ContainerShimmer extends StatelessWidget {
  const ContainerShimmer({super.key, this.height, this.width, this.margin});

  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: Container(
        margin: margin,
        height: height,
        width: width,
        color: Colors.white,
      ),
    );
  }
}

class DrawerHeaderShimmer extends StatelessWidget {
  const DrawerHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 35,
          ),
          const SizedBox(height: 5),
          Container(
            width: 265, // Adjust the width as needed
            height: 16,
            color: Colors.white, // Background color
          ),
          const SizedBox(height: 5),
          Container(
            width: 265, // Adjust the width as needed
            height: 16,
            color: Colors.white, // Background color
          ),
        ],
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({
    super.key,
    required this.itemCount,
    required this.circleAvatarRadius,
  });

  final int itemCount;
  final double circleAvatarRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: circleAvatarRadius,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: 60,
                  height: 16,
                  color: Colors.white,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContainerShimmer(
      height: double.infinity,
      width: double.infinity,
    );
  }
}

class ProductWidgetShimmer extends StatelessWidget {
  const ProductWidgetShimmer({
    super.key,
    required this.containerWidth,
    required this.imageHeight,
    required this.imageWidth,
    required this.nameHeight,
    required this.nameWidth,
    required this.priceHeight,
    required this.priceWidth,
    required this.iconHeight,
    required this.iconWidth,
  });

  final double containerWidth;
  final double imageHeight;
  final double imageWidth;
  final double nameHeight;
  final double nameWidth;
  final double priceHeight;
  final double priceWidth;
  final double iconHeight;
  final double iconWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 0.3,
        ),
      ),
      width: containerWidth,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: const BeveledRectangleBorder(),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerShimmer(
              height: imageHeight,
              width: imageWidth,
            ),
            const SizedBox(height: 2),
            ContainerShimmer(
              height: nameHeight,
              width: nameWidth,
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContainerShimmer(
                  height: priceHeight,
                  width: priceWidth,
                ),
                ContainerShimmer(
                  height: iconHeight,
                  width: iconWidth,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ItemWidgetShimmer extends StatelessWidget {
  const ItemWidgetShimmer({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.hardEdge,
          shape: const BeveledRectangleBorder(),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerShimmer(
                    margin: const EdgeInsets.all(5.0),
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.33,
                  ), // Shimmer for the image
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerShimmer(
                          margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                          height: 25,
                        ),
                        ContainerShimmer(
                          margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ContainerShimmer(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ), // Shimmer for the first button
                  Container(
                    width: 0.5,
                    height: 30,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  Expanded(
                    child: ContainerShimmer(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ), // Shimmer for the second button
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class PriceContainerShimmer extends StatelessWidget {
  const PriceContainerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.hardEdge,
      shape: BeveledRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerShimmer(
              height: 20,
              width: 120,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContainerShimmer(
                  height: 18,
                  width: 50,
                ),
                ContainerShimmer(
                  height: 18,
                  width: 80,
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContainerShimmer(
                  height: 18,
                  width: 80,
                ),
                ContainerShimmer(
                  height: 18,
                  width: 80,
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContainerShimmer(
                  height: 18,
                  width: 150,
                ),
                ContainerShimmer(
                  height: 18,
                  width: 80,
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContainerShimmer(
                  height: 18,
                  width: 120,
                ),
                ContainerShimmer(
                  height: 18,
                  width: 80,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
      color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContainerShimmer(
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            height: 16,
            width: 50,
          ),
          const Divider(),
          ItemWidgetShimmer(itemCount: itemCount),
          const PriceContainerShimmer(),
        ],
      ),
    );
  }
}

class SaveForLaterItemShimmer extends StatelessWidget {
  const SaveForLaterItemShimmer({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
      color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContainerShimmer(
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            height: 16,
            width: 120,
          ),
          const Divider(),
          ItemWidgetShimmer(itemCount: itemCount),
        ],
      ),
    );
  }
}

class CheckoutItemShimmer extends StatelessWidget {
  const CheckoutItemShimmer({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Card(
              clipBehavior: Clip.hardEdge,
              shape: const BeveledRectangleBorder(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerShimmer(
                    margin: const EdgeInsets.all(5.0),
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.32,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerShimmer(
                        margin: EdgeInsets.fromLTRB(8, 5, 8, 0),
                        height: 25,
                        width: 180,
                      ),
                      ContainerShimmer(
                        margin: EdgeInsets.fromLTRB(8, 5, 8, 0),
                        height: 25,
                        width: 160,
                      ),
                      ContainerShimmer(
                        margin: EdgeInsets.fromLTRB(8, 5, 8, 0),
                        height: 25,
                        width: 60,
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
        const PriceContainerShimmer(),
      ],
    );
  }
}

class SettingAddressShimmer extends StatelessWidget {
  const SettingAddressShimmer({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(5.0),
          color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerShimmer(
                      margin: const EdgeInsets.only(bottom: 5),
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                    ContainerShimmer(
                      margin: const EdgeInsets.only(bottom: 2),
                      height: 16,
                      width: MediaQuery.of(context).size.width,
                    ),
                    ContainerShimmer(
                      margin: const EdgeInsets.only(bottom: 5),
                      height: 16,
                      width: MediaQuery.of(context).size.width,
                    ),
                    ContainerShimmer(
                      margin: const EdgeInsets.only(bottom: 5),
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ContainerShimmer(
                  margin: const EdgeInsets.all(8.0),
                  height: MediaQuery.of(context).size.height * 0.025,
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
