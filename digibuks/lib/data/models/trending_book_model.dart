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
    // Helper function to safely parse authors from various formats
    List<String> _parseAuthors(dynamic authorsData) {
      if (authorsData == null) return [];

      if (authorsData is List<dynamic>) {
        // Authors is a list - could be strings or objects
        return authorsData.where((e) => e != null).map((e) {
          if (e is String) {
            return e;
          } else if (e is Map<String, dynamic>) {
            // Extract name from author object
            return e['name']?.toString() ?? e['title']?.toString() ?? 'Unknown';
          }
          return e.toString();
        }).toList();
      } else if (authorsData is Map<String, dynamic>) {
        // Authors is a single author object - extract name
        final name = authorsData['name']?.toString() ??
            authorsData['title']?.toString() ??
            'Unknown';
        return [name];
      } else if (authorsData is String) {
        // Single author as string
        return [authorsData];
      }

      return ['Unknown'];
    }

    return TrendingBookModel(
      id: (json['id'] ?? 'unknown').toString(),
      title: (json['title'] ?? 'Unknown').toString(),
      coverUrl: (json['cover_url'] ?? '').toString(),
      authors: _parseAuthors(json['authors']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isFree: json['is_free'] as bool? ?? false,
      language: (json['language'] ?? 'Unknown').toString(),
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
