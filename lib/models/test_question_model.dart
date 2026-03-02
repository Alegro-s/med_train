class TestQuestion {
  final String id;
  final String testId;
  final String questionText;
  final int orderIndex;

  TestQuestion({
    required this.id,
    required this.testId,
    required this.questionText,
    required this.orderIndex,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'],
      testId: json['test_id'],
      questionText: json['question_text'],
      orderIndex: json['order_index'],
    );
  }
}