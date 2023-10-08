import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:paourtest/data/domain/books_model.dart';

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
}
