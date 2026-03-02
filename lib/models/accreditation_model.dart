enum AccreditationStatus { active, expired }

class Accreditation {
  final String id;
  final String userId;
  final String type;
  final String registrationNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final AccreditationStatus status;
  final String? fileUrl;

  Accreditation({
    required this.id,
    required this.userId,
    required this.type,
    required this.registrationNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    this.fileUrl,
  });

  factory Accreditation.fromJson(Map<String, dynamic> json) {
    return Accreditation(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      registrationNumber: json['registration_number'],
      issueDate: DateTime.parse(json['issue_date']),
      expiryDate: DateTime.parse(json['expiry_date']),
      status: AccreditationStatus.values.firstWhere((e) => e.name == json['status']),
      fileUrl: json['file_url'],
    );
  }
}