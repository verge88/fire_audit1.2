abstract class QuizEvent {}

class StartQuiz extends QuizEvent {}

class JumpToQuestion extends QuizEvent {
  final int index;
  JumpToQuestion(this.index);
}

class AnswerSelected extends QuizEvent {
  final int questionIndex;
  final int selectedOption;
  AnswerSelected(this.questionIndex, this.selectedOption);
}

class QuizFinished extends QuizEvent {
  final int selectedOption;
  QuizFinished(this.selectedOption);
}