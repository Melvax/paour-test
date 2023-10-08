import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/controllers/book_controller.dart';
import 'package:paourtest/controllers/providers/providers.dart';

StateNotifierProvider<LessonController, LessonState> lessonController =
    StateNotifierProvider<LessonController, LessonState>((ref) {
  return LessonController(ref.read(lessonUseCase));
});
