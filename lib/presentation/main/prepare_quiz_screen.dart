import 'package:bloc_quiz/bloc/quiz_data/quiz_data_bloc.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_event.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_state.dart';
import 'package:bloc_quiz/presentation/main/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_quiz/utility/category_detail_list.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../data/repositories/quiz_repo.dart';
import '../../utility/prepare_quiz.dart';
import '../dashboard/categories/categories_screen.dart';

// Список URL-адресов для каждой категории
final List<String> categoryUrls = [

  'https://firebasestorage.googleapis.com/v0/b/quiz-4c367.appspot.com/o/pb.json?alt=media&token=3449d7d7-260a-452a-b597-90315604b019',
  'https://firebasestorage.googleapis.com/v0/b/quiz-4c367.appspot.com/o/pa.json?alt=media&token=627b78a1-77e6-4ad3-b6a2-be593a9f1a38',
  'https://firebasestorage.googleapis.com/v0/b/quiz-4c367.appspot.com/o/pa.json?alt=media&token=627b78a1-77e6-4ad3-b6a2-be593a9f1a38'
  // Добавьте URL-адреса для других категорий
];

class PrepareQuizScreen extends StatelessWidget {
  final int index;
  final String selectedDif;
  final bool isMarathon;
  final int numQuestions; // Add numQuestions parameter
  final PrepareQuiz? quizMaker; // Стандартный QuizMaker
  final GeneratedQuizMaker? generatedQuizMaker; // Новый QuizMaker для генерированных тестов
  final bool useGeneratedQuestions; // New parameter

  const PrepareQuizScreen({
    Key? key,
    required this.index,
    required this.selectedDif,
    this.isMarathon = false,
    required this.numQuestions,
    this.quizMaker,
    this.generatedQuizMaker,
    this.useGeneratedQuestions = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Получите URL для выбранной категории
    String categoryUrl = categoryUrls[index];

    return RepositoryProvider(
        create: (context) => QuizDataRepository(
            useGeneratedQuestions
                ? '' // Pass empty URL for generated questions
                : categoryUrls[index]
        ),
        child: BlocProvider(
            create: (context) => QuizDataBloc(repository: RepositoryProvider.of<QuizDataRepository>(context))
              ..add(DataRequested()),
            child: Container(
                decoration: BoxDecoration(
                  color: categoryDetailList[index].textColor,
                ),
                child: BlocListener<QuizDataBloc, QuizDataState>(
                  listener: (context, state) {
                    if (state is Success) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionsScreen(
                            questionData: state.data,
                            categoryIndex: index,
                            difficultyLevel: selectedDif,
                            isMarathon: isMarathon,
                            numQuestions: numQuestions,
                          ),
                        ),
                      );
                    }
                    if (state is Error) {
                      showDialog(context: context, builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(state.error),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ));
                    }
                  },
                  child: BlocBuilder<QuizDataBloc, QuizDataState>(
                      builder: (context, state) {
                        // state is loading
                        return Scaffold(
                          //backgroundColor: Colors.transparent,
                          body: Center(
                            child: CircularProgressIndicator()
                            // LoadingAnimationWidget.discreteCircle(
                            //   color: Colors.orangeAccent,
                            //   size: 50,
                            // ),
                          ),
                        );
                      }
                  ),
                ))));
  }
}
