import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  UserDetails({
    required this.MobileNumber,
    required this.Email,
    required this.userId,
    required this.Name,
    required this.Password,
    required this.ImageUrl,
    required this.Id,
  });
  late final String MobileNumber;
  late final String Email;
  late final String userId;
  late final String Name;
  late final String Password;
  late final String ImageUrl;
  late final String Id;

  UserDetails.fromJson(DocumentSnapshot json) {
    MobileNumber = json['MobileNumber'];
    Id = json.id;
    Email = json['Email'];
    userId = json['userId'];
    Name = json['Name'];
    Password = json['Password'];
    ImageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['MobileNumber'] = MobileNumber;
    _data['Email'] = Email;
    _data['userId'] = userId;
    _data['Name'] = Name;
    _data['Password'] = Password;
    _data['ImageUrl'] = ImageUrl;
    _data['Id'] = Id;
    return _data;
  }
}
