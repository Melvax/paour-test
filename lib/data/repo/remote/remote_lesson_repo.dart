import 'package:paourtest/data/domain/books_model.dart';

abstract class RemoteLessonRepo {
  Future<List<BookModel>> initBooks();
}
