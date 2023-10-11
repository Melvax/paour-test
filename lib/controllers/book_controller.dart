import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/domain/chapter_model.dart';
import 'package:paourtest/data/domain/exam_list.dart';
import 'package:paourtest/data/service/lesson_service.dart';
import 'package:paourtest/data/usecases/lesson_usecase.dart';

class LessonState {
  final bool loading;

  final List<BookModel> books;
  final List<ExamList> examChapterList;
  final List<String> subjects;
  final List<String> levels;

  const LessonState({
    required this.loading,
    required this.books,
    required this.subjects,
    required this.levels,
    required this.examChapterList,
  });

  LessonState copyWith({
    bool? loading,
    List<BookModel>? books,
    List<String>? subjects,
    List<String>? levels,
    List<ExamList>? examChapterList,
  }) {
    return LessonState(
      loading: loading ?? this.loading,
      books: books ?? this.books,
      subjects: subjects ?? this.subjects,
      levels: levels ?? this.levels,
      examChapterList: examChapterList ?? this.examChapterList,
    );
  }
}

class LessonController extends StateNotifier<LessonState> {
  LessonController(this._lessonUseCase)
      : super(const LessonState(loading: false, books: [], subjects: [], levels: [], examChapterList: []));
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
          print(level);
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
    List<String> orderedLevels = [
      '6ème',
      '5ème',
      '4ème',
      '3ème',
      '2de',
      '2de Bac Pro',
      '1re',
      '1re Bac Pro',
      'Terminale',
      'Terminale Bac Pro'
    ];

    bookResult.sort((a, b) {
      String levelA = a.levels.isNotEmpty ? a.levels[0] : '';
      String levelB = b.levels.isNotEmpty ? b.levels[0] : '';

      int indexA = orderedLevels.indexOf(levelA);
      int indexB = orderedLevels.indexOf(levelB);

      // If level is not found in the orderedLevels list, put it at the end
      if (indexA == -1) indexA = orderedLevels.length;
      if (indexB == -1) indexB = orderedLevels.length;

      return indexA.compareTo(indexB);
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

  Future<void> fetchBooksByFilter({String? subject, String? level, bool examMode = false}) async {
    state = state.copyWith(loading: true);
    List<BookModel> filteredBooks = [];

    List<String> modeExamLevels = ['2de', '2de Bac Pro', '1re', '1re Bac Pro', 'Terminale', 'Terminale Bac Pro'];
    List<BookModel> bookResult = await _lessonUseCase.initBooks();
    LessonServices lessonServices = LessonServices();

    bookResult.removeWhere((book) => book.displayTitle == null);
    filteredBooks = bookResult;
    if (subject != null) {
      filteredBooks = filteredBooks.where((book) => book.subjects.contains(subject)).toList();

      // filteredBooks =
      // filteredBooks = filteredBooks.where((book) => book.levels.contains(level)).toList();
    }
    if (examMode) {
      print('exam mode');
      List<ExamList> examList = [];
      filteredBooks.where((book) => book.levels.any((level) => modeExamLevels.contains(level))).toList();
      sort(filteredBooks);

      for (int i = 0; i < filteredBooks.length; i++) {
        BookModel book = filteredBooks[i];
        String? title = book.displayTitle;
        List<ChapterModel> chapters = [];

        List<ChapterModel> chapterResult = await lessonServices.fetchChapters(book.id);

        for (ChapterModel chap in chapterResult) {
          print(chap.title);
        }

        chapters.addAll(chapterResult);
        if (book.levels.isNotEmpty) {
          print(book.levels.first);
        }
        try {
          examList.add(ExamList(bookTitle: title!, chapters: chapters, level: book.levels[0]));
        } catch (e) {
          print(e);
        }

        print(examList.length);

        // book. = await _lessonUseCase.loadChapters(book.id);
      }

      state = state.copyWith(
        loading: false,
        books: filteredBooks,
        examChapterList: examList,

        // examChapters: chapters,
      );
    } else if (level != null) {
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
