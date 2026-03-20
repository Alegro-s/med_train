import 'package:flutter/material.dart';

enum UserRole { admin, teacher, student, staff }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.student:
        return 'student';
      case UserRole.staff:
        return 'staff';
    }
  }
}

class UserProfile {
  final String id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String? organization;
  final UserRole role;
  final String? position; 
  final String? department; 

  UserProfile({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    this.organization,
    required this.role,
    this.position,
    this.department,
  });

  String get fullName => '$lastName $firstName ${middleName ?? ''}'.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String roleStr = json['role'] ?? 'student';
    UserRole role;
    
    try {
      role = UserRole.values.firstWhere(
        (e) => e.name == roleStr,
        orElse: () => UserRole.student,
      );
    } catch (e) {
      role = UserRole.student;
    }

    return UserProfile(
      id: json['id'] ?? '',
      lastName: json['last_name'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      organization: json['organization'],
      role: role,
      position: json['position'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'organization': organization,
      'role': role.name,
      'position': position,
      'department': department,
    };
  }
}