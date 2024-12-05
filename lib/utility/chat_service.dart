import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;



class ChatService {
  final String baseUrl = 'https://maximum-enrica-verge-6e7172b0.koyeb.app/predict';

  Future<String> sendMessageWithFile({
    required String testName,
    required String questionCount,
    required List<File> files,
    String text = '',
  }) async {
    try {
      // Проверка обязательных полей
      if (testName.isEmpty || questionCount.isEmpty) {
        throw Exception('Название теста и количество вопросов обязательны');
      }

      // Проверка, что либо текст, либо файлы присутствуют
      if (text.isEmpty && files.isEmpty) {
        throw Exception('Необходимо указать текст или прикрепить файл');
      }

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Добавляем текстовые поля
      request.fields['testName'] = testName;
      request.fields['questionCount'] = questionCount;

      // Добавляем текст, если он есть
      if (text.isNotEmpty) {
        request.fields['text'] = text;
      }

      // Добавляем файлы
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      // Отправка запроса
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = json.decode(responseData);

        // Возвращаем SQL-код для добавления вопросов
        return jsonResponse['result'][0][1][0]['text'] ?? 'Пустой ответ';
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка отправки данных: $e');
      rethrow; // Перебрасываем исключение для обработки в вызывающем коде
    }
  }
}
