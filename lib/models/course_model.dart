class Course {
  final String id;
  final String title;
  final String description;
  final String? category;
  final int durationHours;
  final double price;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.durationHours,
    required this.price,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'],
      durationHours: json['duration_hours'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}