import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizDataRepository {
  final String url;

  QuizDataRepository(this.url);

  Future<List<dynamic>> getData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
