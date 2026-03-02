class Certificate {
  final String id;
  final String userId;
  final String courseId;
  final DateTime issueDate;
  final String registrationNumber;
  final String? fileUrl;

  Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.issueDate,
    required this.registrationNumber,
    this.fileUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      issueDate: DateTime.parse(json['issue_date']),
      registrationNumber: json['registration_number'],
      fileUrl: json['file_url'],
    );
  }
}