import 'package:shared_preferences/shared_preferences.dart';

void markChapterAsRead(String chapterId) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> readChapters = prefs.getStringList('readChapters') ?? [];
  if (!readChapters.contains(chapterId)) {
    readChapters.add(chapterId);
    await prefs.setStringList('readChapters', readChapters);
  }
}

Future<bool> isChapterRead(String chapterId) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> readChapters = prefs.getStringList('readChapters') ?? [];
  return readChapters.contains(chapterId);
}
