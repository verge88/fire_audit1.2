import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/model/generator.dart';
import '../../../data/model/questions.dart';
import '../../../utility/questions_db.dart';
import '../../main/question_screen.dart';

class GeneratedTestsScreen extends StatefulWidget {
  @override
  _GeneratedTestsScreenState createState() => _GeneratedTestsScreenState();
}

class _GeneratedTestsScreenState extends State<GeneratedTestsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGeneratedTests();
  }

  Future<void> _loadGeneratedTests() async {
    try {
      final tests = await _databaseHelper.getGeneratedTests();
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки тестов: $e'))
      );
    }
  }

  void _startTest(Map<String, dynamic> test) async {
    try {
      List<Question> questions = await _databaseHelper.getQuestionsForTest(test['id']);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionsScreen(
            questionData: questions,
            categoryIndex: -1,
            difficultyLevel: 'medium',
            isMarathon: false,
            numQuestions: questions.length,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить тест: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сгенерированные тесты'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadGeneratedTests,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Пока нет сгенерированных тестов',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizGenHomePage())
              ),
              child: Text('Создать тест'),
            )
          ],
        ),
      )
          : ListView.builder(
        itemCount: _tests.length,
        itemBuilder: (context, index) {
          final test = _tests[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                  test['name'],
                  style: TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text('Создан: ${test['created_at']}'),
              trailing: Icon(Icons.play_circle, color: Colors.green),
              onTap: () => _startTest(test),
            ),
          );
        },
      ),
    );
  }
}