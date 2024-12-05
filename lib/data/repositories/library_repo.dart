// lib/presentation/library/library_repo.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/law.dart';


class LibraryDataRepository {
  final String url;

  LibraryDataRepository(this.url);

  Future<List<Law>> getLaws() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedData);
        return jsonData.map<Law>((json) => Law.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load laws: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching laws: $e');
    }
  }
}
