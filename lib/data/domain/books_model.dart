class BookModel {
  final int id;
  final String? displayTitle;
  final String? url;
  final List<String> subjects;
  final List<String> levels;
  final bool valid;

  BookModel({
    required this.id,
    this.displayTitle,
    this.url,
    required this.subjects,
    required this.levels,
    required this.valid,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    // print(jsonEncode(json));
    return BookModel(
      id: json['id'] as int,
      displayTitle: json['displayTitle'] as String?,
      url: json['url'] as String?,
      subjects: (json['subjects'] as List).map((x) => x['name'] as String).toList(),
      levels: (json['levels'] as List).map((x) => x['name'] as String).toList(),
      valid: json['valid'] as bool,
    );
  }
}
