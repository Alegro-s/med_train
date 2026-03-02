class TestResult {
  final String id;
  final String userId;
  final String testId;
  final int score;
  final bool isPassed;
  final DateTime completedAt;

  TestResult({
    required this.id,
    required this.userId,
    required this.testId,
    required this.score,
    required this.isPassed,
    required this.completedAt,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      testId: json['test_id'] ?? '',
      score: json['score'] ?? 0,
      isPassed: json['is_passed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'test_id': testId,
      'score': score,
      'is_passed': isPassed,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}