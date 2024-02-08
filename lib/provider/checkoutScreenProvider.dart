import 'package:bakery_user_app/model/address.dart';
import 'package:bakery_user_app/model/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CheckoutScreenProvider with ChangeNotifier {
  List<CartItem> cart = [];
  List<AddressItem> address = [];
  int activeStepIndex = 0;
  int selectedAddressIndex = 0;

  String selectedPaymentMethod = '';

  double calculateSubtotal(List<CartItem> items) {
    double subtotal = 0;

    for (var item in items) {
      double mrp = double.tryParse(item.MRP) ?? 0;
      double price = double.tryParse(item.Price) ?? 0;
      double selectedQuantity = double.tryParse(item.SelecetedQuantity) ?? 0;

      if (mrp > 0 && price > 0 && selectedQuantity > 0) {
        subtotal += (mrp * selectedQuantity);
      }
    }

    return subtotal;
  }

  double calculateDiscount(List<CartItem> items) {
    double discount = 0;

    for (var item in items) {
      double mrp = double.tryParse(item.MRP) ?? 0;
      double price = double.tryParse(item.Price) ?? 0;
      double selectedQuantity = double.tryParse(item.SelecetedQuantity) ?? 0;

      if (mrp > 0 && price > 0 && selectedQuantity > 0) {
        double discountAmount = (mrp - price) * selectedQuantity;
        discount += discountAmount;
      }
    }

    return discount;
  }

  double calculateDeliveryCharges(double subtotal) {
    if (subtotal < 500) {
      return 50;
    } else {
      return 0;
    }
  }

  double calculateTotalAmount(
      double subtotal, double discount, double deliveryCharges) {
    double totalAmount = subtotal - discount + deliveryCharges;

    return totalAmount;
  }

  void updateActiveStepIndex(int index) {
    activeStepIndex = index;
    notifyListeners();
  }

  void updateSelectedAddressIndex(int index) {
    selectedAddressIndex = index;
    notifyListeners();
  }

  void updateSelectedPaymentMethod(String paymentMethod) {
    selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  Future<void> fetchCartData() async {
    try {
      final quearySnapshot = await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Cart')
          .get();
      cart = quearySnapshot.docs.map((e) => CartItem.fromJson(e)).toList();

      double subtotal = calculateSubtotal(cart);
      double discount = calculateDiscount(cart);
      double deliveryCharges = calculateDeliveryCharges(subtotal);
      // ignore: unused_local_variable
      double totalAmount =
          calculateTotalAmount(subtotal, discount, deliveryCharges);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching cart data: $e');
    }
  }

  Future<void> fetchAddressData() async {
    try {
      final quearySnapshot = await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Addresses')
          .get();
      address =
          quearySnapshot.docs.map((e) => AddressItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching address data: $e');
    }
  }
}
