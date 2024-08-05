class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cities,
    required this.hashtags,
    required this.title,
    required this.postDescription,
    required this.category,
    required this.price,
    required this.thumbnail,
  });

  // from Json
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      cities: json['cities'],
      hashtags: json['post_hashtags'],
      title: json['title'],
      postDescription: json['post_description'],
      category: json['category_name'],
      price: double.parse(json['price'].toString()),
      thumbnail: json['thumbnail'],
    );
  }
  final String id;
  final String name;
  final String description;
  final String cities;
  final String hashtags;
  final String title;
  final String postDescription;
  final String category;
  final double price;
  final String thumbnail;
}
