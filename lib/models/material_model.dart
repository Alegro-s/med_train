enum MaterialType { lecture, video, file, test }

class Material {
  final String id;
  final String moduleId;
  final MaterialType type;
  final String title;
  final String? content;
  final int orderIndex;
  final DateTime createdAt;

  Material({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.title,
    this.content,
    required this.orderIndex,
    required this.createdAt,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      moduleId: json['module_id'],
      type: MaterialType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      content: json['content'],
      orderIndex: json['order_index'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}