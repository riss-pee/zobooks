class BookSummaryModel {
  final String id;
  final String title;
  final double price;
  final bool isFree;
  final String coverUrl;
  final List<String> authors;

  BookSummaryModel({
    required this.id,
    required this.title,
    required this.price,
    required this.isFree,
    required this.coverUrl,
    required this.authors,
  });

  factory BookSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookSummaryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isFree: json['is_free'] ?? false,
      coverUrl: json['cover_url'] ?? '',
      authors: json['authors'] != null ? List<String>.from(json['authors']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'is_free': isFree,
      'cover_url': coverUrl,
      'authors': authors,
    };
  }
}

class GroupedBooksModel {
  final String category;
  final List<BookSummaryModel> books;

  GroupedBooksModel({
    required this.category,
    required this.books,
  });

  factory GroupedBooksModel.fromJson(Map<String, dynamic> json) {
    return GroupedBooksModel(
      category: json['category'] ?? '',
      books: json['books'] != null
          ? (json['books'] as List).map((i) => BookSummaryModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'books': books.map((i) => i.toJson()).toList(),
    };
  }
}
