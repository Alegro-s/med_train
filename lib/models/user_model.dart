enum UserRole { student, teacher, admin }

class UserProfile {
  final String id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String? organization;
  final UserRole role;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    this.organization,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      lastName: json['last_name'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      organization: json['organization'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'last_name': lastName,
    'first_name': firstName,
    'middle_name': middleName,
    'organization': organization,
    'role': role.name,
    'created_at': createdAt.toIso8601String(),
  };

  String get fullName => '$lastName $firstName ${middleName ?? ''}'.trim();
}