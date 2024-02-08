import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final String image;
  final void Function() onTap;

  const GridItem({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.3,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: Card(
          margin: const EdgeInsets.all(8),
          shape: const BeveledRectangleBorder(),
          clipBehavior: Clip.hardEdge,
          child: Image(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class GridSection extends StatelessWidget {
  final String title;
  final String firstImage;
  final String secondImage;
  final String thirdImage;
  final String fourthImage;
  final void Function() first;
  final void Function() second;
  final void Function() third;
  final void Function() fourth;

  const GridSection({
    required this.title,
    required this.firstImage,
    required this.secondImage,
    required this.thirdImage,
    required this.fourthImage,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          width: MediaQuery.of(context).size.width,
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children: [
              GridItem(image: firstImage, onTap: first),
              GridItem(image: secondImage, onTap: second),
              GridItem(image: thirdImage, onTap: third),
              GridItem(image: fourthImage, onTap: fourth),
            ],
          ),
        ),
      ],
    );
  }
}
