class TestAnswer {
  final String id;
  final String questionId;
  final String answerText;
  final bool isCorrect;

  TestAnswer({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
  });

  factory TestAnswer.fromJson(Map<String, dynamic> json) {
    return TestAnswer(
      id: json['id'],
      questionId: json['question_id'],
      answerText: json['answer_text'],
      isCorrect: json['is_correct'],
    );
  }
}