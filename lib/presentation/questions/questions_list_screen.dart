import 'package:bloc_quiz/bloc/quiz_data/quiz_data_bloc.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_event.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_state.dart';
import 'package:bloc_quiz/presentation/main/prepare_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../data/repositories/quiz_repo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_bloc.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_event.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_state.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:bloc_quiz/data/repositories/quiz_repo.dart';

class QuestionsListScreen extends StatelessWidget {
  final int categoryIndex;
  final String difficultyLevel;

  QuestionsListScreen({
    Key? key,
    required this.categoryIndex,
    required this.difficultyLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizDataBloc(
        repository: RepositoryProvider.of<QuizDataRepository>(context),
      )..add(DataRequested()),
      child: BlocBuilder<QuizDataBloc, QuizDataState>(
        builder: (context, state) {
          if (state is Success) {
            final questions = state.data;
            return Scaffold(
              appBar: AppBar(
                title: Text('Questions for Category ${categoryIndex + 1}'),
                backgroundColor: Colors.white,
              ),
              body: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final options = question.options;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...options.map((option) => ListTile(
                            title: Text(option),
                            onTap: () {
                              // Handle option tap
                            },
                          )),
                          Text(
                            'Correct Answer: ${question.correctAnswer}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is Error) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.orangeAccent,
                size: 50,
              ),
            );
          }
        },
      ),
    );
  }
}
