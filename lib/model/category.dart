import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryItem {
  CategoryItem({
    required this.Category,
    required this.ImageUrl,
    required this.id,
  });
  late final String Category;
  late final String ImageUrl;
  late final String id;

  CategoryItem.fromJson(DocumentSnapshot json) {
    Category = json['Category'];
    ImageUrl = json['ImageUrl'];
    id = json.id;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Category'] = Category;
    _data['ImageUrl'] = ImageUrl;
    return _data;
  }
}
