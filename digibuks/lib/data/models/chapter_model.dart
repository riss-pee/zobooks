class ChapterModel {
  final String id;
  final String title;
  final int index;
  final String? content;
  final int? wordCount;

  ChapterModel({
    required this.id,
    required this.title,
    required this.index,
    this.content,
    this.wordCount,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      index: json['index'] ?? 0,
      content: json['content'],
      wordCount: json['word_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'index': index,
      'content': content,
      'word_count': wordCount,
    };
  }
}
