class ChapterBookmarkModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String? bookCoverImage;
  final String chapterId;
  final String chapterTitle;
  final int chapterIndex;
  final DateTime? createdAt;

  ChapterBookmarkModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    this.bookCoverImage,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterIndex,
    this.createdAt,
  });

  factory ChapterBookmarkModel.fromJson(Map<String, dynamic> json) {
    // Handle nested book object or flat structure
    String title = 'Unknown';
    String? coverImage;

    if (json['book'] is Map) {
      final bookData = json['book'] as Map<String, dynamic>;
      title = bookData['title'] ?? 'Unknown';
      coverImage = bookData['cover_image'];
    } else {
      title = json['book_title'] ?? 'Unknown';
      coverImage = json['book_cover_image'];
    }

    // Handle location object or flat structure
    String chapterTitle = 'Chapter';
    int chapterIndex = 0;

    if (json['location'] is Map) {
      final locationData = json['location'] as Map<String, dynamic>;
      chapterTitle = locationData['chapter_title'] ?? 'Chapter';
      chapterIndex = locationData['chapter_index'] ?? 0;
    } else {
      chapterTitle = json['chapter_title'] ?? 'Chapter';
      chapterIndex = json['chapter_index'] ?? 0;
    }

    return ChapterBookmarkModel(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      bookTitle: title,
      bookCoverImage: coverImage,
      chapterId: json['chapter_id'] ?? '',
      chapterTitle: chapterTitle,
      chapterIndex: chapterIndex,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'book_title': bookTitle,
      'book_cover_image': bookCoverImage,
      'chapter_id': chapterId,
      'chapter_title': chapterTitle,
      'chapter_index': chapterIndex,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
