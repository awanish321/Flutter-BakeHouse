class BannerItem {
  BannerItem({
    required this.Banner,
    required this.ImageUrl,
  });
  late final String Banner;
  late final String ImageUrl;

  BannerItem.fromJson(Map<String, dynamic> json) {
    Banner = json['Banner'];
    ImageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Banner'] = Banner;
    _data['ImageUrl'] = ImageUrl;
    return _data;
  }
}
