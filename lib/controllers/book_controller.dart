import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/usecases/lesson_usecase.dart';

class LessonState {
  final bool loading;

  final List<BookModel> books;
  final List<String> subjects;

  const LessonState({
    required this.loading,
    required this.books,
    required this.subjects,
  });

  LessonState copyWith({
    bool? loading,
    List<BookModel>? books,
    List<String>? subjects,
  }) {
    return LessonState(
      loading: loading ?? this.loading,
      books: books ?? this.books,
      subjects: subjects ?? this.subjects,
    );
  }
}

class LessonController extends StateNotifier<LessonState> {
  LessonController(this._lessonUseCase) : super(const LessonState(loading: false, books: [], subjects: []));
  final LessonUseCase _lessonUseCase;

  Future<void> fetchInitialBooks() async {
    state = state.copyWith(loading: true);

    List<BookModel> bookResult = await _lessonUseCase.initBooks();

    bookResult.removeWhere((book) => book.displayTitle == null);
    List<String> subjects = [];
    for (var book in bookResult) {
      for (var subject in book.subjects) {
        if (!subjects.contains(subject)) {
          subjects.add(subject);
        }
      }
    }

    state = state.copyWith(
      loading: false,
      books: bookResult,
      subjects: subjects,
    );
  }

  Future<void>? resetAll() {
    state = state.copyWith(
      loading: false,
    );

    return null;
  }
}
