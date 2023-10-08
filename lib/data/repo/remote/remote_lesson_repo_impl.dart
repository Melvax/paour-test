import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/repo/remote/remote_lesson_repo.dart';
import 'package:paourtest/data/service/lesson_service.dart';

class RemoteLessonRepoImpl extends RemoteLessonRepo {
  final LessonServices _lessonServices;

  RemoteLessonRepoImpl(this._lessonServices);

  @override
  Future<List<BookModel>> initBooks() async {
    List<BookModel> books = await _lessonServices.fetchBooks();
    return books;
  }
}
