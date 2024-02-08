import 'package:bakery_user_app/model/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WishlistScreenProvider with ChangeNotifier {
  List<ProductItem> wishlist = [];

  // Move an item to the "Cart" section
  void moveItemToCart(ProductItem item) async {
    try {
      // Remove the item from the "Save for Later" section in Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Wishlist')
          .doc(item.id)
          .delete();

      // Notify listeners after both Firestore and the list have been updated.
      notifyListeners();

      Map<String, dynamic> cartItemData = {
        "Time": FieldValue.serverTimestamp(),
        'SelectedQuantity': '1',
        ...item.toJson(),
      };

      // Add the item to the cart section in Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Cart')
          .add(cartItemData);

      // Notify listeners after the Firestore update.
      notifyListeners();
    } catch (e) {
      debugPrint("Error moving item to the cart: $e");
    }
  }

  // Remove an item from the "Save for Later" section
  void removeFromWishlist(ProductItem item) async {
    try {
      // Remove the item from the "Save for Later" section in Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Wishlist')
          .doc(item.id)
          .delete();

      // Notify listeners after the Firestore update
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing item from Save for Later: $e");
    }
  }

  Future<void> fetchWishlistData() async {
    try {
      final quearySnapshot = await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Wishlist')
          .get();
      wishlist =
          quearySnapshot.docs.map((e) => ProductItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching wishlist data: $e');
    }
  }
}
