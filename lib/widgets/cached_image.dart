import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? height;

  const CachedImage({super.key, required this.imageUrl, this.height});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height,
      width: double.infinity,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: Image(
            image: AssetImage('assets/images/loading.gif'),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
