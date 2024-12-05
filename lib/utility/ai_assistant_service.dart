import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html;  // Для парсинга HTML

class AIAssistantService {
  final String apiKey = '7ab51e185d0e417e81bdf2e160ce43be';
  final String baseUrl = 'https://api.aimlapi.com';
  final String lawDatabaseUrl = 'http://pravo.gov.ru/proxy/ips/?start_search&fattrib=1';

  Future<String> getAIResponse(String userMessage) async {
    try {
      // 1. Сначала загружаем данные из базы по ссылке
      final lawText = await _fetchLawText();

      // 2. Далее делаем запрос к AI
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',

        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'Ты ассистент для эксперта по пожарной безопасности и должен давать текст из запрошенного пользователем документа из этой базы данных: http://publication.pravo.gov.ru/search',
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        print('API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Network error: $e');
    }
  }

  // Метод для извлечения текста из базы данных
  Future<String> _fetchLawText() async {
    try {
      final response = await http.get(Uri.parse(lawDatabaseUrl));

      if (response.statusCode == 200) {
        // Парсим HTML
        final document = html.parse(response.body);

        // Извлекаем нужные данные (например, текст параграфов)
        final lawText = document.body!.text;

        // Обрезаем текст, если он слишком длинный
        return lawText.length > 500 ? lawText.substring(0, 500) + '...' : lawText;
      } else {
        print('Ошибка при загрузке данных из базы: ${response.statusCode}');
        return 'Не удалось загрузить данные из базы.';
      }
    } catch (e) {
      print('Ошибка сети при попытке загрузить данные: $e');
      throw Exception('Ошибка сети: $e');
    }
  }
}
