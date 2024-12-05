class Question {
  final String id;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String? clarification;

  Question({
    required this.id,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.clarification,
  });



  // Метод для преобразования данных в Map для SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'correctAnswer': correctAnswer,
      'incorrectAnswers': incorrectAnswers.join('|'),
      'clarification': clarification,// Преобразуем в строку
    };
  }

  // Метод для конвертации из Map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'].toString(),
      question: map['question'],
      correctAnswer: map['correct_answer'],
      incorrectAnswers: (map['incorrect_answers'] as String).split('|'),
      category: map['category'] ?? '',
      clarification: map['clarification'] ?? '',
    );
  }
}
