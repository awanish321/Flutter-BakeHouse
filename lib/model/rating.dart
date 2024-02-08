import 'package:cloud_firestore/cloud_firestore.dart';

class RatingItem {
  RatingItem({
    required this.Rating,
    required this.Review,
    required this.Image,
    required this.Name,
    required this.Reply,
    required this.id,
  });
  late final String Rating;
  late final String Review;
  late final String Image;
  late final String Name;
  late final String Reply;
  late final String id;

  RatingItem.fromJson(DocumentSnapshot json) {
    Rating = json['Rating'];
    Review = json['Review'];
    Image = json['Image'];
    Name = json['Name'];
    Reply = json['Reply'];
    id = json.id;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Rating'] = Rating;
    _data['Review'] = Review;
    _data['Image'] = Image;
    _data['Name'] = Name;
    _data['Reply'] = Reply;
    return _data;
  }
}
