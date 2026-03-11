class BookModel {
  final String id;
  final String title;
  final String? description;
  final String authorId;
  final String? authorName;
  final String? coverImage;
  final String? fileUrl;
  final String fileType; // pdf, epub
  final String language;
  final List<String> genres;
  final List<String> tags;
  final double? price;
  final double? rentalPrice;
  final int? rentalDays;
  final String type; // purchase, rental, free
  final bool isPublished;
  final double? rating;
  final int? reviewCount;
  final int? pageCount;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    required this.title,
    this.description,
    required this.authorId,
    this.authorName,
    this.coverImage,
    this.fileUrl,
    required this.fileType,
    required this.language,
    this.genres = const [],
    this.tags = const [],
    this.price,
    this.rentalPrice,
    this.rentalDays,
    required this.type,
    this.isPublished = false,
    this.rating,
    this.reviewCount,
    this.pageCount,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'],
      coverImage: json['cover_image'],
      fileUrl: json['file_url'],
      fileType: json['file_type'] ?? 'pdf',
      language: json['language'] ?? 'english',
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      price: json['price']?.toDouble(),
      rentalPrice: json['rental_price']?.toDouble(),
      rentalDays: json['rental_days'],
      type: json['type'] ?? 'purchase',
      isPublished: json['is_published'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      pageCount: json['page_count'],
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  factory BookModel.fromPublishedBookJson(Map<String, dynamic> json) {
    final authors = (json['authors'] as List<dynamic>?)
            ?.map((author) => author.toString())
            .toList() ??
        const <String>[];
    final categories = (json['categories'] as List<dynamic>?)
            ?.map((category) => category.toString())
            .toList() ??
        const <String>[];
    final priceValue = json['price'];
    final isFree = json['is_free'] == true;

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      authorId: '',
      authorName: authors.isNotEmpty ? authors.join(', ') : null,
      coverImage: json['cover_url']?.toString(),
      fileUrl: null,
      fileType: 'pdf',
      language: json['language']?.toString() ?? 'english',
      genres: categories,
      tags: const [],
      price: priceValue is num ? priceValue.toDouble() : null,
      rentalPrice: null,
      rentalDays: null,
      type: isFree ? 'free' : 'purchase',
      isPublished: true,
      rating: null,
      reviewCount: null,
      pageCount: json['chapters_count'] is num
          ? (json['chapters_count'] as num).toInt()
          : null,
      publishedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author_id': authorId,
      'author_name': authorName,
      'cover_image': coverImage,
      'file_url': fileUrl,
      'file_type': fileType,
      'language': language,
      'genres': genres,
      'tags': tags,
      'price': price,
      'rental_price': rentalPrice,
      'rental_days': rentalDays,
      'type': type,
      'is_published': isPublished,
      'rating': rating,
      'review_count': reviewCount,
      'page_count': pageCount,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
