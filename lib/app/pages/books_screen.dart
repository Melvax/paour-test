import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paourtest/controllers/book_controller.dart';
import 'package:paourtest/controllers/providers/state_providers.dart';

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
                    : Column(
                        children: bookState.books
                            .map(
                              (book) => Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      book.displayTitle ?? "nuull",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
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
                                              print("valid");
                                            } else {
                                              print("invalid");
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
                                  SizedBox(height: 20),
                                ],
                              ),
                            )
                            .toList(),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
