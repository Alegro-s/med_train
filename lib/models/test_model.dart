class Test {
  final String id;
  final String moduleId;
  final String title;
  final int passingScore;

  Test({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.passingScore,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      moduleId: json['module_id'],
      title: json['title'],
      passingScore: json['passing_score'],
    );
  }
}