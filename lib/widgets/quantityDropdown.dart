import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuantityDropdown extends StatefulWidget {
  const QuantityDropdown(
      {super.key,
      required this.initialSelectedQuantity,
      required this.cartItemId});

  final String initialSelectedQuantity;
  final String cartItemId;

  @override
  State<QuantityDropdown> createState() => _QuantityDropdownState();
}

class _QuantityDropdownState extends State<QuantityDropdown> {
  String _selectedQuantity = '';

  @override
  void initState() {
    super.initState();
    _selectedQuantity = widget.initialSelectedQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: Theme.of(context).colorScheme.onSecondary,
      value: _selectedQuantity,
      items: <String>['1', '2', '3', '4', '5'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        );
      }).toList(),
      onChanged: (newValue) async {
        setState(() {
          _selectedQuantity = newValue!;
        });

        try {
          await FirebaseFirestore.instance
              .collection('Wishlist')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .collection('Cart')
              .doc(widget.cartItemId)
              .update({'SelectedQuantity': newValue.toString()});
        } catch (e) {
          print("Error updating document: $e");
        }
      },
    );
  }
}
