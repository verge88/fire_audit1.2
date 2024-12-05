import 'package:bloc_quiz/bloc/quiz/quiz_event.dart';
import 'package:bloc_quiz/bloc/quiz/quiz_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../utility/prepare_quiz.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final PrepareQuiz quizMaker;
  final bool isMarathon;

  QuizBloc(this.quizMaker, this.isMarathon) : super(QuizInitial(questions: [])) {
    on<StartQuiz>((event, emit) {
      final questions = List.generate(
        quizMaker.getTotalQuestions(),
            (index) => {
          'questionText': quizMaker.getQuestion(index),
          'options': quizMaker.getOptions(index),
          'selectedOptionIndex': -1,
          'correctOptionIndex': quizMaker.getOptions(index).indexOf(quizMaker.getCorrectAnswer(index)),
          'isCorrect': false,
        },
      );

      final allOptions = List.generate(
        quizMaker.getTotalQuestions(),
            (index) {
          // Получаем варианты и перемешиваем их
          List<String> options = quizMaker.getOptions(index);
          options.shuffle();
          return options;
        },
      );

      // Генерация пояснений
      final clarifications = List.generate(
        quizMaker.getTotalQuestions(),
            (index) => quizMaker.getClarification(index),
      );

      // Генерация индексов правильных ответов для каждого вопроса
      final correctOptionIndices = List.generate(
        quizMaker.getTotalQuestions(),
            (index) {
          String correctAnswer = quizMaker.getCorrectAnswer(index);
          List<String> options = allOptions[index];
          return options.indexOf(correctAnswer); // Индекс правильного ответа в перемешанном списке
        },
      );

      emit(QuizOnGoingState(
        correctOptionIndices: correctOptionIndices, // Сохраняем индексы правильных ответов
        currentIndex: 0,
        totalQuestions: quizMaker.getTotalQuestions(),
        questions: questions,
        allOptions: allOptions,
        selectedOptions: List.filled(quizMaker.getTotalQuestions(), -1),
        currentScore: 0,
        currentAttempts: 0,
        currentWrongAttempts: 0,
        currentCorrectAttempts: 0,
        clarifications: clarifications, // Передаем пояснения в состояние
      ));
    });

    on<JumpToQuestion>((event, emit) {
      if (state is QuizOnGoingState) {
        final currentState = state as QuizOnGoingState;
        emit(currentState.copyWith(currentIndex: event.index));
      }
    });

    on<AnswerSelected>((event, emit) {
      if (state is QuizOnGoingState) {
        final currentState = state as QuizOnGoingState;

        final List<int> newSelectedOptions = List<int>.from(currentState.selectedOptions);
        // Проверяем, был ли уже дан ответ на этот вопрос
        if (currentState.selectedOptions[event.questionIndex] != -1) {
          // Если ответ уже был дан, просто обновляем выбранный вариант
          newSelectedOptions[event.questionIndex] = event.selectedOption;

          emit(currentState.copyWith(
            selectedOptions: newSelectedOptions,
          ));
        } else {
          // Если это первый ответ на вопрос
          newSelectedOptions[event.questionIndex] = event.selectedOption;

          bool isCorrect = event.selectedOption == currentState.correctOptionIndices[event.questionIndex];


        final questionText = currentState.questions[event.questionIndex];
        final options = currentState.allOptions[event.questionIndex];
        final correctOptionIndex = currentState.correctOptionIndices[event.questionIndex];

        emit(currentState.copyWith(
          selectedOptions: newSelectedOptions,
          currentScore: isCorrect ? currentState.currentScore + 1 : currentState.currentScore,
          currentAttempts: currentState.currentAttempts + 1,
          currentCorrectAttempts: isCorrect ? currentState.currentCorrectAttempts + 1 : currentState.currentCorrectAttempts,
          currentWrongAttempts: !isCorrect ? currentState.currentWrongAttempts + 1 : currentState.currentWrongAttempts,
        ));

        // Создаем и добавляем AnswerSubmitted событие
        add(AnswerSubmitted(
          questionIndex: event.questionIndex,
          selectedOptionIndex: event.selectedOption,
          isCorrect: isCorrect,
          questionText: questionText as String,
          options: options,
          correctOptionIndex: correctOptionIndex,
        ));
      }
    }});


    on<QuizFinished>((event, emit) {
      if (state is QuizOnGoingState) {
        final currentState = state as QuizOnGoingState;
        emit(QuizFinishedState(
          currentScore: currentState.currentScore,
          currentAttempts: currentState.currentAttempts,
          currentWrongAttempts: currentState.currentWrongAttempts,
          currentCorrectAttempts: currentState.currentCorrectAttempts,
          questions: currentState.questions,
        ));
      }
    });

    on<AnswerSubmitted>((event, emit) {
      if (state is QuizOnGoingState) {
        final currentState = state as QuizOnGoingState;

        final List<Map<String, dynamic>> newQuestions = List<Map<String, dynamic>>.from(currentState.questions);

        // Обновляем соответствующий вопрос
        newQuestions[event.questionIndex] = {
          'questionText': event.questionText,
          'options': event.options,
          'selectedOptionIndex': event.selectedOptionIndex,
          'correctOptionIndex': event.correctOptionIndex,
          'isCorrect': event.isCorrect,
        };

        emit(currentState.copyWith(
          questions: newQuestions,
        ));
      }
    });

  }
}
class AnswerSubmitted extends QuizEvent {
  final int questionIndex;
  final int selectedOptionIndex;
  final bool isCorrect;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  AnswerSubmitted({
    required this.questionIndex,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}