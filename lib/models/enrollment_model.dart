enum EnrollmentStatus { inProgress, completed }

extension EnrollmentStatusExtension on EnrollmentStatus {
  String get name {
    switch (this) {
      case EnrollmentStatus.inProgress:
        return 'in_progress';
      case EnrollmentStatus.completed:
        return 'completed';
    }
  }
}

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
    print('📦 Парсим Enrollment: $json'); 
    
    String statusStr = json['status'] ?? 'in_progress';
    EnrollmentStatus status;
    
    try {
      status = EnrollmentStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => EnrollmentStatus.inProgress,
      );
    } catch (e) {
      status = EnrollmentStatus.inProgress;
    }

    return Enrollment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? '',
      status: status,
      progressPercent: json['progress_percent'] ?? 0,
      enrolledAt: json['enrolled_at'] != null 
          ? DateTime.parse(json['enrolled_at']) 
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'status': status.name,
      'progress_percent': progressPercent,
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}