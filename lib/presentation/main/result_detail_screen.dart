import 'package:bloc_quiz/data/repositories/result_repo.dart';
import 'package:flutter/material.dart';
import 'package:fl_score_bar/fl_score_bar.dart';
import 'package:bloc_quiz/utility/category_detail_list.dart';

class ResultDetailScreen extends StatefulWidget {
  final double score;
  final int categoryIndex;
  //final String difficultyLevel;
  final int attempts;
  final int wrongAttempts;
  final int correctAttempts;
  final bool isSaved;
  final List<Map<String, dynamic>> questions;

  // Устанавливаем максимальный балл
  static const double maxScore = 70.0;

  final ResultRepo resultRepo = ResultRepo();

  ResultDetailScreen({
    Key? key,
    required this.score,
    required this.categoryIndex,
    required this.attempts,
    required this.wrongAttempts,
    required this.correctAttempts,
    //required this.difficultyLevel,
    required this.questions,
    required this.isSaved,
  }) : super(key: key);

  @override
  _ResultDetailScreenState createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Проверяем, что балл не превышает максимальный балл
    final finalScore = widget.score <= ResultDetailScreen.maxScore ? widget.score : ResultDetailScreen.maxScore;

    // Если результат еще не сохранен, сохраняем его
    if (!widget.isSaved) {
      widget.resultRepo.saveScore(
        finalScore,
        widget.attempts,
        widget.wrongAttempts,
        widget.correctAttempts,
        categoryDetailList[widget.categoryIndex].title,
        widget.categoryIndex,
        widget.questions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String resultText = widget.score > 60 ? 'Тест пройден' : 'Тест не пройден';

    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
        title: Text('Результат'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   '${categoryDetailList[widget.categoryIndex].title} ${widget.difficultyLevel}',
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //     color: Theme.of(context).colorScheme.primary,
            //   ),
            // ),
            //const SizedBox(height: 30),
            // IconScoreBar(
            //   scoreIcon: Icons.star_rounded,
            //   iconColor: Colors.white,
            //   score: (widget.score / 2).clamp(0.0, 7.0), // Убедитесь, что score не превышает maxScore (7)
            //   maxScore: 7,
            //   readOnly: true,
            // ),
            //const SizedBox(height: 30),
            Text(
              'Баллов набрано ${widget.score.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Ответов: ${widget.attempts}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Неправильных ответов: ${widget.wrongAttempts}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Правильных ответов: ${widget.correctAttempts}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              resultText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: widget.score > 60 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  return ExpansionTile(
                    title: Text(question['questionText'] as String),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: question['options'].length,
                        itemBuilder: (context, optionIndex) {
                          return ListTile(
                            title: Text(question['options'][optionIndex] as String),
                            tileColor: question['selectedOptionIndex'] == optionIndex
                                ? question['isCorrect']
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3)
                                : Colors.white,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Уменьшение радиуса скругления
                ),
              ),
              child: Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }
}