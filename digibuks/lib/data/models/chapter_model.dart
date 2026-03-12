class ChapterModel {
  final String id;
  final String title;
  final int index;
  final int wordCount;
  final String sectionType;

  ChapterModel({
    required this.id,
    required this.title,
    required this.index,
    required this.wordCount,
    required this.sectionType,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      index: json['index'] ?? 0,
      wordCount: json['word_count'] ?? 0,
      sectionType: json['section_type'] ?? 'chapter',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'index': index,
      'word_count': wordCount,
      'section_type': sectionType,
    };
  }
}
