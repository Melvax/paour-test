import 'package:paourtest/data/domain/chapter_model.dart';

class ExamList {
  final String bookTitle;
  final List<ChapterModel> chapters;
  final String level;

  ExamList({
    required this.bookTitle,
    required this.chapters,
    required this.level,
  });
}
