import 'package:flutter/foundation.dart';

import 'package:bakery_user_app/model/banner.dart';
import 'package:bakery_user_app/model/category.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreenProvider with ChangeNotifier {
  List<CategoryItem> category = [];
  List<BannerItem> banner = [];
  List<ProductItem> product = [];
  int activeIndex = 0;

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

  void updateActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }
}
