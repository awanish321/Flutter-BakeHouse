import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  OrderItem({
    required this.UserName,
    required this.Address,
    required this.Amount,
    required this.PaymentMethod,
    required this.Items,
    required this.UserPhoneNumber,
    required this.OrderId,
    required this.UserEmail,
    required this.id,
  });
  late final String UserName;
  late final String Address;
  late final String Amount;
  late final String PaymentMethod;
  late final List<ItemsData> Items;
  late final String UserPhoneNumber;
  late final int OrderId;
  late final String UserEmail;
  late final String id;

  OrderItem.fromJson(DocumentSnapshot json) {
    UserName = json['UserName'];
    Address = json['Address'];
    Amount = json['Amount'];
    PaymentMethod = json['PaymentMethod'];
    Items = List.from(json['Items']).map((e) => ItemsData.fromJson(e)).toList();
    UserPhoneNumber = json['UserPhoneNumber'];
    OrderId = json['OrderId'];
    UserEmail = json['UserEmail'];
    id = json.id;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['UserName'] = UserName;
    _data['Address'] = Address;
    _data['Amount'] = Amount;
    _data['PaymentMethod'] = PaymentMethod;
    _data['Items'] = Items.map((e) => e.toJson()).toList();
    _data['UserPhoneNumber'] = UserPhoneNumber;
    _data['OrderId'] = OrderId;
    _data['UserEmail'] = UserEmail;
    return _data;
  }
}

class ItemsData {
  ItemsData({
    required this.Price,
    required this.Product,
    required this.ImageUrl,
    required this.SelecetedQuantity,
  });
  late final String Price;
  late final String Product;
  late final String ImageUrl;
  late final String SelecetedQuantity;

  ItemsData.fromJson(Map<String, dynamic> json) {
    Price = json['Price'];
    Product = json['Product'];
    ImageUrl = json['ImageUrl'];
    SelecetedQuantity = json['SelecetedQuantity'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Price'] = Price;
    _data['Product'] = Product;
    _data['ImageUrl'] = ImageUrl;
    _data['SelecetedQuantity'] = SelecetedQuantity;
    return _data;
  }
}
