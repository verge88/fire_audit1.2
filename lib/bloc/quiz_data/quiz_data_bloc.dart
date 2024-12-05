import 'package:bloc_quiz/bloc/quiz_data/quiz_data_event.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_state.dart';
import 'package:bloc/bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../data/model/questions.dart';
import '../../data/repositories/quiz_repo.dart';
import '../../utility/questions_db.dart';

class QuizDataBloc extends Bloc<QuizDataEvent, QuizDataState> {

  final QuizDataRepository repository;
  final bool useGeneratedQuestions;

  QuizDataBloc({required this.repository, this.useGeneratedQuestions = false}) : super(Loading()) {
    on<DataRequested>((event, emit) async {
      emit(Loading());
      try {
        bool result = await checkConnectivity();

        if (useGeneratedQuestions) {
          // Fetch generated questions directly from the database
          List<Question> generatedQuestions =
          await DatabaseHelper.instance.fetchGeneratedQuestions();

          if (generatedQuestions.isEmpty) {
            emit(Error('Нет сгенерированных вопросов'));
            return;
          }

          emit(Success(generatedQuestions));

        } else {
          final data = await repository.getData();
          emit(Success(data));

        }
      } catch (e) {
        emit(Error(e.toString()));
      }
    });
  }

  Future<bool> checkConnectivity() async {
    bool result = await InternetConnectionChecker().hasConnection;
    return result;
  }

}