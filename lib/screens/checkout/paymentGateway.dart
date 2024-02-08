import 'package:flutter/material.dart';

import 'package:bakery_user_app/widgets/appBar.dart';

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Payment Gateway', context: context),
    );
  }
}
