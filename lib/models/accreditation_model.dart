enum AccreditationStatus { active, expired, pending }

class Accreditation {
  final String id;
  final String userId;
  final String type;
  final String registrationNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final AccreditationStatus status;
  final String? fileUrl;
  final String? documentName;
  final DateTime? uploadedAt;
  final bool isVerified;

  Accreditation({
    required this.id,
    required this.userId,
    required this.type,
    required this.registrationNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    this.fileUrl,
    this.documentName,
    this.uploadedAt,
    this.isVerified = false,
  });

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
  
  bool get isExpiring => daysLeft < 30 && daysLeft >= 0;
  
  bool get isExpired => daysLeft < 0;

  factory Accreditation.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'pending';
    AccreditationStatus status;
    
    try {
      status = AccreditationStatus.values.firstWhere(
        (e) => e.name == statusStr,
      );
    } catch (e) {
      status = AccreditationStatus.pending;
    }

    return Accreditation(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      issueDate: json['issue_date'] != null 
          ? DateTime.parse(json['issue_date']) 
          : DateTime.now(),
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : DateTime.now().add(const Duration(days: 365)),
      status: status,
      fileUrl: json['file_url'],
      documentName: json['document_name'],
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.parse(json['uploaded_at']) 
          : null,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'registration_number': registrationNumber,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'status': status.name,
      'file_url': fileUrl,
      'document_name': documentName,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'is_verified': isVerified,
    };
  }
}