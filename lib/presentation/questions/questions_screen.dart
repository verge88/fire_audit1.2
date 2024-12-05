import 'package:flutter/material.dart';
import '../../data/model/questions.dart';
import '../../data/repositories/quiz_repo.dart';
import '../../utility/questions_db.dart';
import '../dashboard/categories/categories_screen.dart';
import '../main/prepare_quiz_screen.dart';

class QuestionsScreen extends StatefulWidget {
  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late Future<List<Question>> independentAssessmentQuestions;
  late Future<List<Question>> generatedQuestions;

  late Future<List<Map<String, dynamic>>> testsList;

  @override
  void initState() {
    super.initState();
    independentAssessmentQuestions = fetchIndependentAssessmentQuestions();
    generatedQuestions = fetchGeneratedQuestions();
    testsList = DatabaseHelper.instance.getAllTests();
  }

  Future<List<Question>> fetchIndependentAssessmentQuestions() async {
    // Заглушка для получения списка вопросов (независимая оценка)
    return await DatabaseHelper.instance.fetchQuestions();
  }

  Future<List<Question>> fetchGeneratedQuestions() async {
    // Заглушка для получения списка сгенерированных вопросов
    return await DatabaseHelper.instance.fetchGeneratedQuestions();
  }

  void navigateToQuestions(BuildContext context, String title, Future<List<Question>> questionsFuture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsListScreen(title: title, questionsFuture: questionsFuture),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            // Существующие карточки
            Card(
              child: ListTile(
                title: Text("Независимая оценка пожарного риска"),
                onTap: () => navigateToQuestions(context, "Независимая оценка", independentAssessmentQuestions),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Сгенерированные вопросы"),
                onTap: () => navigateToQuestions(context, "Сгенерированные вопросы", generatedQuestions),
              ),
            ),
            // Список созданных тестов
            Card(
              child: ExpansionTile(
                title: Text("Созданные тесты"),
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: testsList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('Тесты не найдены');
                      }
                      return Column(
                        children: snapshot.data!.map((test) => ListTile(
                          title: Text(test['name']),
                          subtitle: Text('Создан: ${test['created_at']}'),
                          onTap: () => navigateToTestQuestions(context, test['id'], test['name']),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void navigateToTestQuestions(BuildContext context, int testId, String testName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsListScreen(
          title: testName,
          questionsFuture: Future.value(DatabaseHelper.instance.fetchTestQuestions(testId)),
        ),
      ),
    );
  }


}

class QuestionsListScreen extends StatefulWidget {
  final String title;
  final Future<List<Question>> questionsFuture;

  QuestionsListScreen({required this.title, required this.questionsFuture});

  @override
  _QuestionsListScreenState createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  late Future<List<Question>> questionsFuture;

  @override
  void initState() {
    super.initState();
    questionsFuture = widget.questionsFuture;
  }

  void _deleteQuestion(String id) async {
    try {
      await DatabaseHelper.instance.deleteGeneratedQuestion(id);
      setState(() {
        questionsFuture = DatabaseHelper.instance.fetchGeneratedQuestions();
      });
    } catch (e) {
      print('Ошибка при удалении вопроса: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Question>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Вопросы не найдены.'));
          }

          List<Question> questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              Question question = questions[index];
              List<String> options = [...question.incorrectAnswers, question.correctAnswer];
              options.shuffle();

              return Dismissible(
                key: ValueKey(question.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteQuestion(question.id); // Удаление вопроса
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Вопрос удален')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: ExpansionTile(
                    title: Text(question.question),
                    children: options.map((option) => ListTile(title: Text(option))).toList()
                      ..add(
                        ListTile(
                          title: Text(
                            'Правильный ответ: ${question.correctAnswer}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

