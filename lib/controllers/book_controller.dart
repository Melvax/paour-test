import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/usecases/lesson_usecase.dart';

class LessonState {
  final bool loading;

  final List<BookModel> books;

  const LessonState({
    required this.loading,
    required this.books,
  });

  LessonState copyWith({
    bool? loading,
    List<BookModel>? books,
  }) {
    return LessonState(
      loading: loading ?? this.loading,
      books: books ?? this.books,
    );
  }
}

class LessonController extends StateNotifier<LessonState> {
  LessonController(this._lessonUseCase) : super(const LessonState(loading: false, books: []));
  final LessonUseCase _lessonUseCase;

  Future<void> fetchInitialBooks() async {
    print("fetch initial books");

    state = state.copyWith(loading: true);

    List<BookModel> bookResult = await _lessonUseCase.initBooks();
    for (var book in bookResult) {
      print(book.url);
    }
    bookResult.removeWhere((book) => book.displayTitle == null);

    state = state.copyWith(
      loading: false,
      books: bookResult,
    );
  }

  Future<void>? resetAll() {
    state = state.copyWith(
      loading: false,
    );

    return null;
  }
}
