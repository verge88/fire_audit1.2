import 'package:flutter/material.dart';
import '../../../data/model/generator.dart';
import '../../../data/model/questions.dart';
import '../../../utility/prepare_quiz.dart';
import '../../../utility/questions_db.dart';

import '../../main/prepare_quiz_screen.dart';
import '../../main/question_screen.dart';
import 'generated_tests_screen.dart';


class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
          margin:
          const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [




              FilledButton.tonal(
                onPressed: () {
                  _showDialog(context, "Экзамен", 70);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Уменьшение радиуса скругления
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 30), // Иконка в левой части
                    SizedBox(width: 10), // Отступ между иконкой и текстом
                    Text(
                      'Экзамен',
                      style: TextStyle(fontSize: 24), // Увеличение размера текста
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Расстояние между кнопками

              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PrepareQuizScreen(
                    index: 1,
                    selectedDif: '',
                    numQuestions: 800, // Set numQuestions for marathon
                  )));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Уменьшение радиуса скругления
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.run_circle, size: 30), // Иконка в левой части
                    SizedBox(width: 10), // Отступ между иконкой и текстом
                    Text(
                      'Марафон',
                      style: TextStyle(fontSize: 24), // Увеличение размера текста
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Расстояние между кнопками

              FilledButton.tonal(
                onPressed: () async {
                  // Получаем список тестов
                  List<Map<String, dynamic>> tests = await DatabaseHelper.instance.getAllTests();

                  // Показываем диалог со списком тестов
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Мои тесты'),
                        content: Container(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tests.length,
                            itemBuilder: (context, index) {
                              var test = tests[index];
                              return ListTile(
                                title: Text(test['name']),
                                subtitle: Text('Создан: ${test['created_at']}'),
                                onTap: () {
                                  Navigator.of(context).pop(); // Закрываем диалог
                                  navigateToGeneratedTestQuiz(context, test['id'], test['name']);
                                },
                              );
                            },
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Закрыть'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Мои тесты',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),

              /*const SizedBox(height: 5),
              ListView.builder(
                itemCount: 1 /*categoryDetailList.length*/,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return CategoryItem(0  /*index*/);
                },
              ),*/

              const SizedBox(height: 20), // Расстояние между кнопками

              // В существующем виджете главного меню
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GeneratedTestsScreen())
                  );
                },
                child: Text('Мои сгенерированные тесты'),
              ),

              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuizGenHomePage()));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Уменьшение радиуса скругления
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.create, size: 30), // Иконка в левой части
                    SizedBox(width: 10), // Отступ между иконкой и текстом
                    Text(
                      'Создать тест',
                      style: TextStyle(fontSize: 24), // Увеличение размера текста
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class GeneratedTestsListScreen extends StatefulWidget {
  @override
  _GeneratedTestsListScreenState createState() => _GeneratedTestsListScreenState();
}

class _GeneratedTestsListScreenState extends State<GeneratedTestsListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _tests = [];

  @override
  void initState() {
    super.initState();
    _loadGeneratedTests();
  }

  Future<void> _loadGeneratedTests() async {
    final tests = await _databaseHelper.getGeneratedTests();
    setState(() {
      _tests = tests;
    });
  }

  void _startTest(Map<String, dynamic> test) async {
    List<Question> questions = await _databaseHelper.getQuestionsForTest(test['id']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          questionData: questions,
          categoryIndex: 2, // Специальный индекс для сгенерированных тестов
          difficultyLevel: '', // Можно добавить уровень сложности в тест
          isMarathon: false,
          numQuestions: questions.length,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сгенерированные тесты')),
      body: _tests.isEmpty
          ? Center(child: Text('Нет сгенерированных тестов'))
          : ListView.builder(
        itemCount: _tests.length,
        itemBuilder: (context, index) {
          final test = _tests[index];
          return ListTile(
            title: Text(test['name']),
            trailing: Icon(Icons.play_arrow),
            onTap: () => _startTest(test),
          );
        },
      ),
    );
  }
}


void navigateToGeneratedTestQuiz(BuildContext context, int testId, String testName) async {
  // Получаем вопросы теста
  List<Question> testQuestions = await DatabaseHelper.instance.fetchTestQuestionsById(testId);

  // Создаем GeneratedQuizMaker
  GeneratedQuizMaker quizMaker = GeneratedQuizMaker(testQuestions);

  // Переход к экрану с сгенерированным тестом
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => PrepareQuizScreen(
      index: 2, // Индекс для сгенерированных тестов
      selectedDif: '',
      numQuestions: testQuestions.length,
      generatedQuizMaker: quizMaker,
    ),
  ));
}




void _showDialog(BuildContext context, String title, int numQuestions) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text(title)),
        content: Container(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Количество вопросов: $numQuestions', style: TextStyle(fontSize: 18),),
              Text('Время на выполнение: 80 мин', style: TextStyle(fontSize: 18),), // Замените на соответствующее значение
              Text('Минимум правильных ответов: 60', style: TextStyle(fontSize: 18),), // Замените на соответствующее значение
            ],
          ),

        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Начать'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PrepareQuizScreen(
                index: title == 'Экзамен' ? 0 : 1,
                selectedDif: '',
                numQuestions: numQuestions,
              )));
            },
          ),
        ],
      );
    },
  );


}




