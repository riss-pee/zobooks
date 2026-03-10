class TrendingBookModel {
  final String id;
  final String title;
  final String coverUrl;
  final List<String> authors;
  final double price;
  final bool isFree;
  final String language;

  TrendingBookModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.authors,
    required this.price,
    required this.isFree,
    required this.language,
  });

  factory TrendingBookModel.fromJson(Map<String, dynamic> json) {
    return TrendingBookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String,
      authors: (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      price: (json['price'] as num).toDouble(),
      isFree: json['is_free'] as bool,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_url': coverUrl,
      'authors': authors,
      'price': price,
      'is_free': isFree,
      'language': language,
    };
  }
}
