import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:paourtest/data/domain/books_model.dart';
import 'package:paourtest/data/domain/chapter_model.dart';

class LessonServices {
  Future<List<BookModel>> fetchBooks() async {
    final HttpLink httpLink = HttpLink('https://api-preprod.lelivrescolaire.fr/graph');

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    );

    final QueryOptions options = QueryOptions(
      document: gql(
        'query{viewer{books{hits{id displayTitle url subjects{name}levels{name}valid}}}}',
      ),
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception('Failed to load books');
    }

    var bookList = result.data?['viewer']['books']['hits'] as List;

    return bookList.map((book) => BookModel.fromJson(book as Map<String, dynamic>)).toList();
  }

  Future<List<ChapterModel>> fetchChapters(int bookId) async {
    final HttpLink httpLink = HttpLink('https://api-preprod.lelivrescolaire.fr/graph');

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    );

    final QueryOptions options = QueryOptions(
      document: gql(
        'query chapters(\$bookId:Int){viewer{chapters(bookIds:[\$bookId]){hits{id title url valid}}}}',
      ),
      variables: {
        "bookId": bookId,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception('Failed to load chapters');
    }

    var chapterList = result.data?['viewer']['chapters']['hits'] as List;

    return chapterList.map((chapter) => ChapterModel.fromJson(chapter as Map<String, dynamic>)).toList();
  }
}
