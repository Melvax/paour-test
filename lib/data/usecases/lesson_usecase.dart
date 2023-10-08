import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/repo/remote/remote_lesson_repo.dart';

class LessonUseCase {
  final RemoteLessonRepo _lessonRepo;

  LessonUseCase(this._lessonRepo);

  Future<List<BookModel>> initBooks() async {
    return await _lessonRepo.initBooks();
  }
}
