enum EnrollmentStatus { inProgress, completed }

class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final EnrollmentStatus status;
  final int progressPercent;
  final DateTime enrolledAt;
  final DateTime? completedAt;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.status,
    required this.progressPercent,
    required this.enrolledAt,
    this.completedAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      status: EnrollmentStatus.values.firstWhere((e) => e.name == json['status']),
      progressPercent: json['progress_percent'] ?? 0,
      enrolledAt: DateTime.parse(json['enrolled_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}