import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class QuizState {
  final double currentScore;
  final int currentAttempts;
  final int currentWrongAttempts;
  final int currentCorrectAttempts;
  final List<Map<String, dynamic>> questions;


  QuizState({
    this.currentScore = 0,
    this.currentAttempts = 0,
    this.currentWrongAttempts = 0,
    this.currentCorrectAttempts = 0,
    required this.questions,
  });


}

class QuizInitial extends QuizState {
  QuizInitial({required List<Map<String, dynamic>> questions}) : super(questions: questions);
}

class QuizOnGoingState extends QuizState {
  final int currentIndex;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final List<List<String>> allOptions;
  final List<int> selectedOptions;
  final List<int> correctOptionIndices; // Добавляем индексы правильных ответов
  final List<String?> clarifications;

  QuizOnGoingState({
    required this.currentIndex,
    required this.totalQuestions,
    required this.questions,
    required this.allOptions,
    required this.selectedOptions,
    required this.correctOptionIndices,
    required this.clarifications,
    // Инициализируем clarifications
    double currentScore = 0,
    int currentAttempts = 0,
    int currentWrongAttempts = 0,
    int currentCorrectAttempts = 0,
  }) : super(
    currentScore: currentScore,
    currentAttempts: currentAttempts,
    currentWrongAttempts: currentWrongAttempts,
    currentCorrectAttempts: currentCorrectAttempts,
    questions: questions
  );

  QuizOnGoingState copyWith({
    int? currentIndex,
    int? totalQuestions,
    List<Map<String, dynamic>>? questions,
    List<List<String>>? allOptions,
    List<int>? selectedOptions,
    double? currentScore,
    int? currentAttempts,
    int? currentWrongAttempts,
    int? currentCorrectAttempts,
    List<int>? correctOptionIndices,
    List<String?>? clarifications,
  }) {
    return QuizOnGoingState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
      allOptions: allOptions ?? this.allOptions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      currentScore: currentScore ?? this.currentScore,
      currentAttempts: currentAttempts ?? this.currentAttempts,
      currentWrongAttempts: currentWrongAttempts ?? this.currentWrongAttempts,
      currentCorrectAttempts: currentCorrectAttempts ?? this.currentCorrectAttempts,
      correctOptionIndices: correctOptionIndices ?? this.correctOptionIndices,
      clarifications: clarifications ?? this.clarifications,

    );
  }
}

class QuizFinishedState extends QuizState {
  QuizFinishedState({
    required double currentScore,
    required int currentAttempts,
    required int currentWrongAttempts,
    required int currentCorrectAttempts,
    required List<Map<String, dynamic>> questions
  }) : super(
    currentScore: currentScore,
    currentAttempts: currentAttempts,
    currentWrongAttempts: currentWrongAttempts,
    currentCorrectAttempts: currentCorrectAttempts,
    questions: questions
  );
}