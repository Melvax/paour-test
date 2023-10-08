import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/data/repo/remote/remote_lesson_repo.dart';
import 'package:paourtest/data/repo/remote/remote_lesson_repo_impl.dart';
import 'package:paourtest/data/service/lesson_service.dart';
import 'package:paourtest/data/usecases/lesson_usecase.dart';

Provider<LessonServices> lessonServicesProvider = Provider<LessonServices>((ref) => LessonServices());

Provider<LessonUseCase> lessonUseCase = Provider<LessonUseCase>((ref) {
  return LessonUseCase(ref.read(lessonRepoProvider));
});

Provider<RemoteLessonRepo> lessonRepoProvider = Provider<RemoteLessonRepo>((ref) {
  LessonServices lessonServices = ref.read(lessonServicesProvider);
  return RemoteLessonRepoImpl(lessonServices);
});
