import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/controllers/book_controller.dart';
import 'package:paourtest/controllers/providers/state_providers.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/domain/chapter_model.dart';
import 'package:paourtest/data/service/lesson_service.dart';
import 'package:paourtest/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({super.key});

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  String? selectedSubject;
  String? selectedLevel;
  bool examMode = false;

  @override
  void initState() {
    super.initState();
    initBooks();
  }

  initBooks() async {
    await ref.read(lessonController.notifier).fetchInitialBooks();
  }

  @override
  Widget build(BuildContext context) {
    LessonState bookState = ref.watch(lessonController);

    return Scaffold(
        body: SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            // collapsedHeight: 1,
            // title: const Text('Books'),
            backgroundColor: Colors.white,
            expandedHeight: 200.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bookState.loading
                              ? const CircularProgressIndicator()
                              : Column(children: [
                                  const SizedBox(height: 20),
                                  SwitchListTile(
                                    title: const Text('Exam Mode'),
                                    value: examMode, //ref.watch(lessonController).examMode,
                                    onChanged: (bool value) {
                                      // print(value);
                                      setState(() {
                                        examMode = value;
                                      });

                                      ref.read(lessonController.notifier).fetchBooksByFilter(
                                            examMode: value,
                                            subject: selectedSubject,
                                            level: selectedLevel,
                                          );
                                    },
                                  ),
                                  DropdownButton<String>(
                                    hint: Text(selectedSubject ?? 'sujet'),
                                    onChanged: (value) async {
                                      setState(() {
                                        selectedSubject = value;
                                      });
                                      await ref
                                          .read(lessonController.notifier)
                                          .fetchBooksByFilter(subject: value, level: selectedLevel, examMode: examMode);
                                    },
                                    items: bookState.subjects.map((subject) {
                                      return DropdownMenuItem<String>(
                                        value: subject,
                                        child: Text(subject),
                                      );
                                    }).toList(),
                                  ),
                                  DropdownButton<String>(
                                    hint: Text(selectedLevel ?? 'niveau'),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLevel = value;
                                      });
                                      ref
                                          .read(lessonController.notifier)
                                          .fetchBooksByFilter(level: value, subject: selectedSubject);
                                    },
                                    items: bookState.levels.map((level) {
                                      return DropdownMenuItem<String>(
                                        value: level,
                                        child: Text(level),
                                      );
                                    }).toList(),
                                  ),
                                ])
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: examMode
                ? Column(
                    children: [
                      ...bookState.examChapterList
                          .map((chapter) => Column(
                                children: [
                                  if (chapter.chapters.isNotEmpty)
                                    ExpansionTile(
                                      title: Text(
                                        chapter.bookTitle,
                                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
                                      ),
                                      children: chapter.chapters
                                          .map(
                                            (chapter) => InkWell(
                                              onTap: () {
                                                if (chapter.valid) {
                                                  setState(() {
                                                    markChapterAsRead(chapter.id.toString());
                                                  });
                                                }
                                              },
                                              child: ListTile(
                                                leading: SizedBox(
                                                  width: 50,
                                                  child: CachedNetworkImage(
                                                    imageUrl: chapter.url,
                                                    height: 140,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) =>
                                                        Image.asset("assets/img/placeholder.png"),
                                                  ),
                                                ),
                                                title: Text(
                                                  chapter.title,
                                                  style: TextStyle(
                                                    color: Paint().color = chapter.valid ? Colors.black : Colors.grey,
                                                  ),
                                                ),
                                                trailing: FutureBuilder<bool>(
                                                  future: isChapterRead(chapter.id.toString()),
                                                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                                    if (snapshot.hasData && snapshot.data == true) {
                                                      return Icon(Icons.check, color: Colors.green);
                                                    } else {
                                                      return SizedBox
                                                          .shrink(); // Return an empty widget if chapter is not read
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    )
                                ],
                              ))
                          .toList(),
                      SizedBox(height: 32),
                    ],
                  )
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      ...bookState.books
                          .map(
                            (book) => Column(
                              children: [
                                Text(book.displayTitle ?? ""),
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (book.valid) {
                                            log("valid");
                                            showDialog(
                                              context: context,
                                              builder: (context) => Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 120.0),
                                                child: ChapterView(book: book),
                                              ),
                                            );
                                          }
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: book.url ?? "assets/img/placeholder.png",
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Image.asset("assets/img/placeholder.png"),
                                        ),
                                      ),
                                      if (!book.valid)
                                        Container(
                                          height: 140,
                                          width: double.infinity,
                                          color: Colors.grey.withOpacity(0.8),
                                        )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
          ),
        ],
      ),
    ));
  }
}

class ChapterView extends StatefulWidget {
  final BookModel book;

  const ChapterView({
    super.key,
    required this.book,
  });

  @override
  State<ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  LessonServices lessonServices = LessonServices();
  List<ChapterModel> chapters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        chapters = await lessonServices.fetchChapters(widget.book.id);
        setState(() {
          chapters = chapters;
        });

        // await ref.read(lessonController.notifier).fetchInitialBooks();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: widget.book.url ?? "assets/img/placeholder.png",
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Image.asset("assets/img/placeholder.png"),
            ),
            const SizedBox(height: 20),
            Text(
              widget.book.displayTitle ?? "",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) => Material(
                  child: InkWell(
                    onTap: () {
                      if (chapters[index].valid) {
                        setState(() {
                          markChapterAsRead(chapters[index].id.toString());
                        });
                      }
                    },
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        child: CachedNetworkImage(
                          imageUrl: chapters[index].url,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Image.asset("assets/img/placeholder.png"),
                        ),
                      ),
                      title: Text(
                        chapters[index].title,
                        style: TextStyle(
                          color: Paint().color = chapters[index].valid ? Colors.black : Colors.grey,
                        ),
                      ),
                      trailing: FutureBuilder<bool>(
                        future: isChapterRead(chapters[index].id.toString()),
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return Icon(Icons.check, color: Colors.green);
                          } else {
                            return SizedBox.shrink(); // Return an empty widget if chapter is not read
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
