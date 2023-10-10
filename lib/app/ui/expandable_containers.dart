import 'package:flutter/material.dart';
import 'package:paourtest/data/domain/books_model.dart';

class ExpandableContainer extends StatefulWidget {
  final BookModel book;
  const ExpandableContainer({Key? key, required this.book}) : super(key: key);

  // this.book = book;

  @override
  ExpandableContainerState createState() => ExpandableContainerState();
}

class ExpandableContainerState extends State<ExpandableContainer> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isExpanded ? 200 : 50,
        child: isExpanded
            ? ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  leading: SizedBox(
                    width: 50,
                    child: Image.network(widget.book.url ?? ""),
                  ),
                  title: Text('Item ${index + 1}'),
                ),
              )
            : Center(child: Text(widget.book.displayTitle ?? 'null', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
