class Score {
  final String id;
  final String uid;
  final DateTime time;
  final String category;
  final int categoryIndex;
  final String score;
  final int attempts;
  final int wrongAttempts;
  final int correctAttempts;
  final List<Map<String, dynamic>> questions;

  Score(
      this.attempts,
      this.wrongAttempts,
      this.correctAttempts,
      this.uid,
      this.time,
      this.score,
      this.category,
      this.categoryIndex,
      this.id,
      this.questions,
      );

  Map<String, dynamic> toJson() => {
    'userId': uid,
    'time': time,
    'score': score,
    'category': category,
    'categoryIndex': categoryIndex,
    'id': id,
    'attempts': attempts,
    'wrongAttempts': wrongAttempts,
    'correctAttempts': correctAttempts,
    'questions': questions,
  };
}