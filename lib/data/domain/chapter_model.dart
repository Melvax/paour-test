class ChapterModel {
  final int id;
  final String title;
  final String url;
  final bool valid;

  ChapterModel({required this.id, required this.title, required this.url, required this.valid});

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      valid: json['valid'] as bool,
    );
  }
}
