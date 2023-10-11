import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/usecases/lesson_usecase.dart';

class LessonState {
  final bool loading;

  final List<BookModel> books;
  final List<String> subjects;
  final List<String> levels;

  const LessonState({
    required this.loading,
    required this.books,
    required this.subjects,
    required this.levels,
  });

  LessonState copyWith({
    bool? loading,
    List<BookModel>? books,
    List<String>? subjects,
    List<String>? levels,
  }) {
    return LessonState(
      loading: loading ?? this.loading,
      books: books ?? this.books,
      subjects: subjects ?? this.subjects,
      levels: levels ?? this.levels,
    );
  }
}

class LessonController extends StateNotifier<LessonState> {
  LessonController(this._lessonUseCase) : super(const LessonState(loading: false, books: [], subjects: [], levels: []));
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
    List<String> levels = [];
    for (var book in bookResult) {
      for (var level in book.levels) {
        if (!levels.contains(level)) {
          levels.add(level);
        }
      }
    }

    sort(bookResult);

    state = state.copyWith(
      loading: false,
      books: bookResult,
      subjects: subjects,
      levels: levels,
    );
  }

  void sort(List<BookModel> bookResult) {
    sortBySubject(bookResult);
    sortByLevel(bookResult);
  }

  void sortByLevel(List<BookModel> bookResult) {
    bookResult.sort((a, b) {
      String levelA = a.levels.isNotEmpty ? a.levels[0] : '';
      String levelB = b.levels.isNotEmpty ? b.levels[0] : '';
      return levelA.compareTo(levelB);
    });
  }

  void sortBySubject(List<BookModel> bookResult) {
    bookResult.sort((a, b) {
      String subjectA = a.subjects.isNotEmpty ? a.subjects[0] : '';
      String subjectB = b.subjects.isNotEmpty ? b.subjects[0] : '';
      return subjectA.compareTo(subjectB);
    });
  }

  Future<void>? resetAll() {
    state = state.copyWith(
      loading: false,
    );

    return null;
  }

  Future<void> fetchBooksByFilter({String? subject, String? level}) async {
    state = state.copyWith(loading: true);

    List<BookModel> filteredBooks = [];
    List<BookModel> bookResult = await _lessonUseCase.initBooks();
    filteredBooks = bookResult;
    if (subject != null) {
      filteredBooks = filteredBooks.where((book) => book.subjects.contains(subject)).toList();
    }
    if (level != null) {
      filteredBooks = filteredBooks.where((book) => book.levels.contains(level)).toList();
    }

    // filteredBooks.sort((a, b) {
    //   int compare = a.levels[0].compareTo(b.levels[0]);
    //   if (compare != 0) {
    //     return compare;
    //   } else {
    //     return a.subjects[0].compareTo(b.subjects[0]);
    //   }
    // });

    sort(filteredBooks);
    state = state.copyWith(
      loading: false,
      books: filteredBooks,
    );
  }
}
