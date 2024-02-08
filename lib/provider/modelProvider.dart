import 'package:flutter/foundation.dart';

import 'package:bakery_user_app/model/address.dart';
import 'package:bakery_user_app/model/banner.dart';
import 'package:bakery_user_app/model/cart.dart';
import 'package:bakery_user_app/model/category.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/model/rating.dart';
import 'package:bakery_user_app/model/userDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModelProvider with ChangeNotifier {
  List<UserDetails> user = [];
  List<BannerItem> banner = [];
  List<CategoryItem> category = [];
  List<ProductItem> product = [];
  List<RatingItem> rating = [];
  List<CartItem> cart = [];
  List<ProductItem> wishlist = [];
  List<CartItem> saveForLater = [];
  List<AddressItem> address = [];

  Future<void> fetchUserData() async {
    try {
      final quearySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      user = quearySnapshot.docs.map((e) => UserDetails.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> fetchBannerData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Banner').get();
      banner = querySnapshot.docs
          .map((doc) => BannerItem.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching banner data: $e');
    }
  }

  Future<void> fetchCategoryData() async {
    try {
      final quearySnapshot =
          await FirebaseFirestore.instance.collection('Category').get();
      category =
          quearySnapshot.docs.map((e) => CategoryItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching category data: $e');
    }
  }

  Future<void> fetchProductData() async {
    try {
      final quearySnapshot =
          await FirebaseFirestore.instance.collection('Product').get();
      product =
          quearySnapshot.docs.map((e) => ProductItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching product data: $e');
    }
  }

  Future<void> fetchRatingData() async {
    try {
      final quearySnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .doc(product.first.id)
          .collection('Rating')
          .get();
      rating = quearySnapshot.docs.map((e) => RatingItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching rating data: $e');
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching cart data: $e');
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
