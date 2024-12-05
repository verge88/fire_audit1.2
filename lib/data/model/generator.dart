import 'dart:convert';
import 'dart:io';
import 'package:bloc_quiz/data/model/questions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../presentation/main/question_screen.dart';
import '../../utility/chat_service.dart';
import '../../utility/questions_db.dart';

class QuizGenHomePage extends StatefulWidget {
  @override
  _QuizGenHomePageState createState() => _QuizGenHomePageState();
}

class _QuizGenHomePageState extends State<QuizGenHomePage> {
  final ChatService _chatService = ChatService();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _questionCountController = TextEditingController();
  final TextEditingController _sourceTextController = TextEditingController();

  List<Map<String, dynamic>> _createdTests = [];

  List<File> _attachedFiles = [];
  bool _isLoading = false;

  Future<void> _loadCreatedTests() async {
    final tests = await _databaseHelper.getAllTests();
    setState(() {
      _createdTests = tests;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCreatedTests();
  }
  // Метод для начала теста
  void _startTest(int testId, String testName) async {
    List<Question> testQuestions = await _databaseHelper.getTestQuestions(testId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          questionData: testQuestions,
          categoryIndex: -1, // Специальный индекс для сгенерированных тестов
          difficultyLevel: 'medium', // Можно динамически определять
          isMarathon: false,
          numQuestions: testQuestions.length,
        ),
      ),
    );
  }



  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _attachedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }
  bool _isCreating = false;

  Future<void> _createTest() async {
    String testName = _testNameController.text.trim();
    String questionCount = _questionCountController.text.trim();
    String sourceText = _sourceTextController.text.trim();

    // Проверяем обязательные поля
    if (testName.isEmpty || questionCount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Пожалуйста, заполните название теста и количество вопросов.'),
      ));
      return;
    }

    // Проверяем корректность количества вопросов
    if (int.tryParse(questionCount) == null || int.parse(questionCount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Введите корректное количество вопросов.'),
      ));
      return;
    }

    // Проверяем, что либо текст, либо файлы присутствуют
    if (sourceText.isEmpty && _attachedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Необходимо указать исходный текст или прикрепить файл.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
      _isCreating = true;
    });

    try {
      final response = await _chatService.sendMessageWithFile(
        testName: testName,
        questionCount: questionCount,
        text: sourceText,
        files: _attachedFiles,
      );

      // Создаем новый тест в базе данных
      int testId = await _databaseHelper.createTest(testName);

      // Парсим SQL и создаем вопросы
      List<Question> questions = _parseQuestionsFromSql(response);

      // Сохраняем вопросы в базу данных
      await _databaseHelper.saveQuestionsToTest(testId, questions);

      // Также добавляем в общую таблицу сгенерированных вопросов
      await _databaseHelper.insertGeneratedQuestions(questions);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Тест "$testName" успешно создан!'),
      ));

      // Очистка полей после создания
      _testNameController.clear();
      _questionCountController.clear();
      _sourceTextController.clear();
      setState(() {
        _attachedFiles = [];
        _isCreating = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка при создании теста: $e'),
      ));
      setState(() {
        _isCreating = false;
      });
    }
  }

  List<Question> _parseQuestionsFromSql(String sqlCode) {
    // Парсинг SQL-кода и создание списка вопросов
    List<Question> questions = [];
    LineSplitter.split(sqlCode).forEach((line) {
      if (line.startsWith('INSERT INTO')) {
        // Регулярное выражение для извлечения данных
        final match = RegExp(r"VALUES\(NULL, '(.*?)', '(.*?)', '(.*?)'").firstMatch(line);
        if (match != null) {
          questions.add(Question(
            id: '',
            question: match.group(1)!,
            correctAnswer: match.group(2)!,
            incorrectAnswers: match.group(3)!.split('|'),
            category: '',
            clarification: '',
          ));
        }
      }
    });
    return questions;
  }

  Future<void> _addQuestionsToDatabase(String sqlCode) async {
    try {
      final db = await _databaseHelper.database;

      String cleanedString = sqlCode
          .replaceAll(RegExp(r'^```sql\s*|\s*```$'), '')
          .replaceAll(RegExp(r'<.*?>'), '')
          .trim();

      List<String> sqlStatements = cleanedString
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();


      await db.execute(cleanedString);


      print('Вопросы успешно добавлены в базу данных.');
    } catch (e) {
      print('Ошибка при добавлении вопросов в базу данных: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать тест'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _testNameController,
                enabled: !_isCreating,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.grey, // Цвет подсказки
                    fontSize: 16.0, // Размер шрифта подсказки
                    fontStyle: FontStyle.normal, // Стиль шрифта подсказки
                  ),
                  labelText: 'Название теста',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _questionCountController,
                enabled: !_isCreating,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.grey, // Цвет подсказки
                    fontSize: 16.0, // Размер шрифта подсказки
                    fontStyle: FontStyle.normal, // Стиль шрифта подсказки
                  ),
                  labelText: 'Количество вопросов',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _sourceTextController,
                enabled: !_isCreating,
                maxLines: 5,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.grey, // Цвет подсказки
                    fontSize: 16.0, // Размер шрифта подсказки
                    fontStyle: FontStyle.normal, // Стиль шрифта подсказки
                  ),
                  labelText: 'Исходный текст',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _isCreating ? null : _pickFiles,
                icon: Icon(Icons.attach_file),
                label: Text('Прикрепить файл'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Укажите желаемое значение закругления
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              if (_attachedFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Прикреплено файлов: ${_attachedFiles.length}',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              SizedBox(height: 18.0),
              FilledButton.tonal(
                onPressed: _isCreating ? null : _createTest,
                child: _isCreating
                    ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                )
                    : Text('Создать'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Укажите желаемое значение закругления
                  ),
                  elevation: 1,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
