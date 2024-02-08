import 'package:flutter/material.dart';

class PriceShow extends StatelessWidget {
  const PriceShow(
      {super.key,
      required this.MRP,
      required this.Price,
      required this.first,
      required this.second,
      required this.third});

  final String MRP;
  final String Price;
  final TextStyle first;
  final TextStyle second;
  final TextStyle third;

  String calculateDiscountPercentage(String mrp, String price) {
    double mrpValue = double.tryParse(mrp) ?? 0;
    double priceValue = double.tryParse(price) ?? 0;

    if (mrpValue <= 0 || priceValue <= 0) {
      return '0';
    }

    double discountPercentage =
        ((mrpValue - priceValue) / mrpValue * 100).roundToDouble();
    return discountPercentage.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${calculateDiscountPercentage(MRP, Price)}% Off',
          style: first,
        ),
        const SizedBox(width: 10),
        Text(
          MRP,
          style: second,
        ),
        const SizedBox(width: 10),
        Text(
          '₹${Price}',
          style: third,
        ),
      ],
    );
  }
}
