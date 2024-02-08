import 'package:cloud_firestore/cloud_firestore.dart';

class Nutrition {
  Nutrition({
    required this.nutritions,
  });
  late final List<String> nutritions;

  Nutrition.fromJson(Map<String, dynamic> json) {
    nutritions = List.castFrom<dynamic, String>(json['Nutritions']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Nutritions'] = nutritions;
    return _data;
  }
}

class ProductItem {
  ProductItem({
    required this.Description,
    required this.Ingredients,
    required this.ImageUrl,
    required this.Product,
    required this.Nutritions,
    required this.Weight,
    required this.Quantity,
    required this.MRP,
    required this.Price,
    required this.Category,
    required this.SubCategory,
    required this.id,
  });
  late final String Description;
  late final String Ingredients;
  late final List<String> ImageUrl;
  late final String Product;
  late final Nutrition Nutritions;
  late final String Weight;
  late final String Quantity;
  late final String MRP;
  late final String Price;
  late final String Category;
  late final String SubCategory;
  late final String id;

  ProductItem.fromJson(DocumentSnapshot json) {
    Description = json['Description'];
    Ingredients = json['Ingredients'];
    ImageUrl = List.castFrom<dynamic, String>(json['ImageUrl']);
    Product = json['Product'];
    Nutritions = Nutrition.fromJson(json['Nutritions']);
    Weight = json['Weight'];
    Quantity = json['Quantity'];
    MRP = json['MRP'];
    Price = json['Price'];
    Category = json['Category'];
    SubCategory = json['SubCategory'];
    id = json.id;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Description'] = Description;
    _data['Ingredients'] = Ingredients;
    _data['ImageUrl'] = ImageUrl;
    _data['Product'] = Product;
    _data['Nutritions'] = Nutritions.toJson();
    _data['Weight'] = Weight;
    _data['Quantity'] = Quantity;
    _data['MRP'] = MRP;
    _data['Price'] = Price;
    _data['Category'] = Category;
    _data['SubCategory'] = SubCategory;
    return _data;
  }
}
