import 'package:bloc_quiz/data/model/questions.dart';
import 'package:bloc_quiz/utility/questions_db.dart';


/// This class is used to create quiz from local SQLite database
class PrepareQuiz {
  List<Question> _questionList = [];

  Future<void> populateList({int? numQuestions, bool useGeneratedQuestions = false}) async {
    try {
      // Получаем вопросы из базы данных
      List<Question> questions;
      if (useGeneratedQuestions) {
        // Загружаем сгенерированные вопросы
        questions = await DatabaseHelper.instance.fetchGeneratedQuestions();
      } else {
        // Загружаем стандартные вопросы
        questions = await DatabaseHelper.instance.fetchQuestions();
      }

      if (questions.isEmpty) {
        print('Нет доступных вопросов');
        return;
      }
      // Перемешиваем вопросы для случайного порядка
      questions.shuffle();
      // Если numQuestions не задано, используем все вопросы
      final count = numQuestions ?? questions.length;
      // Ограничиваем количество вопросов
      final maxCount = count > questions.length ? questions.length : count;
      _questionList = questions.take(maxCount).toList();
      print('Загружено ${_questionList.length} вопросов');
    } catch (e) {
      print('Ошибка при подготовке викторины: $e');
      _questionList = [];
    }
  }

  String getQuestion(int i) {
    if (i >= 0 && i < _questionList.length) {
      return _questionList[i].question;
    }
    return 'Вопрос не найден';
  }

  List<String> getOptions(int i) {
    if (i >= 0 && i < _questionList.length) {
      List<String> options = [..._questionList[i].incorrectAnswers];
      options.add(_questionList[i].correctAnswer);
      options.shuffle();
      return options;
    }
    return [];
  }

  bool isCorrect(int i, int selectedOption) {
    if (i >= 0 && i < _questionList.length) {
      List<String> options = getOptions(i);
      return options[selectedOption] == _questionList[i].correctAnswer;
    }
    return false;
  }

  int getTotalQuestions() {
    return _questionList.length;
  }

  // Новый метод для получения правильного ответа
  String getCorrectAnswer(int i) {
    return _questionList[i].correctAnswer; // Возвращает правильный ответ для данного вопроса
  }

  // Новый метод для получения пояснения
  String? getClarification(int i) {
    if (i >= 0 && i < _questionList.length) {
      return _questionList[i].clarification;
    }
    return null;
  }
}
class GeneratedQuizMaker {
  final List<Question> questions;

  GeneratedQuizMaker(this.questions);

  int getTotalQuestions() => questions.length;

  String getQuestion(int index) => questions[index].question;

  List<String> getOptions(int index) {
    final allOptions = [...questions[index].incorrectAnswers, questions[index].correctAnswer];
    allOptions.shuffle();
    return allOptions;
  }

  String getCorrectAnswer(int index) => questions[index].correctAnswer;

  String getClarification(int index) => questions[index].clarification ?? '';
}