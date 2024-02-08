import 'package:bakery_user_app/model/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CartScreenProvider with ChangeNotifier {
  List<CartItem> cart = [];
  List<CartItem> saveForLater = [];

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

  // Move an item to the "Save for Later" section
  void moveToSaveForLater(CartItem item) async {
    try {
      // Remove the item from Firestore first.
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Cart')
          .doc(item.id)
          .delete();

      // Remove the item from the cart list after the Firestore delete operation.
      cart.removeWhere((cartItem) => cartItem.id == item.id);

      // Notify listeners after both Firestore and the list have been updated.
      notifyListeners();

      // Add the item to the "Save for Later" section in Firestore.
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('SaveForLater')
          .add(item.toJson());

      // Notify listeners after the Firestore update.
      notifyListeners();
    } catch (e) {
      debugPrint("Error moving item to Save for Later: $e");
    }
  }

  void removeCartItem(String cartItemId) async {
    // Find the item in the cartItems list and remove it based on the provided cartItemId.
    final itemIndex = cart.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      // Use await to make sure the item is removed from Firestore before updating the list.
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Cart')
          .doc(cartItemId)
          .delete();

      // Notify listeners after both Firestore and the list have been updated.
      notifyListeners();
    } else {
      debugPrint('Item with ID $cartItemId not found in the cart.');
    }
  }

  // Move an item to the "Cart" section
  void moveItemToCart(CartItem item) async {
    try {
      // Remove the item from the "Save for Later" section in Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('SaveForLater')
          .doc(item.id)
          .delete();

      // Notify listeners after both Firestore and the list have been updated.
      notifyListeners();

      // Add the item to the cart section in Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Cart')
          .add(item.toJson());

      // Notify listeners after the Firestore update.
      notifyListeners();
    } catch (e) {
      debugPrint("Error moving item to the cart: $e");
    }
  }

  // Remove an item from the "Save for Later" section
  void removeFromSaveForLater(CartItem item) async {
    try {
      // Remove the item from the "Save for Later" section in Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('SaveForLater')
          .doc(item.id)
          .delete();

      // Notify listeners after the Firestore update
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing item from Save for Later: $e");
    }
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

  Future<void> fetchSaveForLaterData() async {
    try {
      final quearySnapshot = await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('SaveForLater')
          .get();
      saveForLater =
          quearySnapshot.docs.map((e) => CartItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching save for later data: $e');
    }
  }
}
