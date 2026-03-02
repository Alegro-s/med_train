class CourseModule {
  final String id;
  final String courseId;
  final String title;
  final int orderIndex;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.orderIndex,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      orderIndex: json['order_index'],
    );
  }
}