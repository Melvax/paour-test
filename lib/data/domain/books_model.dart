import 'package:shared_preferences/shared_preferences.dart';

class BookModel {
  final int id;
  final String? displayTitle;
  final String? url;
  final List<String> subjects;
  final List<String> levels;
  final bool valid;
  bool read;

  BookModel({
    required this.id,
    this.displayTitle,
    this.url,
    required this.subjects,
    required this.levels,
    required this.valid,
    this.read = false,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
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

class UserPreferences {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> saveReadChapters(List<int> readChapters) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setStringList('readChapters', readChapters.map((i) => i.toString()).toList());
  }

  static Future<List<int>> loadReadChapters() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList('readChapters')?.map(int.parse).toList() ?? [];
  }
}
