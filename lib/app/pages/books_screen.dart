import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/controllers/book_controller.dart';
import 'package:paourtest/controllers/providers/state_providers.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/domain/chapter_model.dart';
import 'package:paourtest/data/service/lesson_service.dart';

class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({super.key});

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await ref.read(lessonController.notifier).fetchInitialBooks();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LessonState bookState = ref.watch(lessonController);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bookState.loading
                    ? const CircularProgressIndicator()
                    : Column(children: [
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
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 32.0, vertical: 120.0),
                                                  child: ChapterView(book: book),
                                                ),
                                              );
                                            }
                                          },
                                          child: CachedNetworkImage(
                                            imageUrl: book.url ?? "",
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
                      ])
              ],
            ),
          ),
        ),
      ),
    );
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
              imageUrl: widget.book.url ?? "",
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
              // height: 300,
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) => Material(
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
                    title: Text(chapters[index].title),
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
