import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../services/module_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/auth_service.dart';
import '../../models/course_model.dart';
import '../../models/module_model.dart';
import '../../widgets/loading_indicator.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final CourseService _courseService;
  late final ModuleService _moduleService;
  late final EnrollmentService _enrollmentService;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _courseService = context.read<CourseService>();
    _moduleService = context.read<ModuleService>();
    _enrollmentService = context.read<EnrollmentService>();
    _checkEnrollment();
  }

  Future<void> _checkEnrollment() async {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return;
    final enrolled = await _enrollmentService.isEnrolled(userId, widget.courseId);
    setState(() => _isEnrolled = enrolled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Курс')),
      body: FutureBuilder<Course?>(
        future: _courseService.getCourseById(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Курс не найден'));
          }
          final course = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(course.description),
                    const SizedBox(height: 16),
                    Text('Длительность: ${course.durationHours} ч'),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<CourseModule>>(
                  future: _moduleService.getModulesForCourse(widget.courseId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }
                    final modules = snap.data ?? [];
                    return ListView.builder(
                      itemCount: modules.length,
                      itemBuilder: (_, i) {
                        final m = modules[i];
                        return ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text(m.title),
                          onTap: _isEnrolled ? () => context.push('/module/${m.id}') : null,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _isEnrolled
                    ? const Text('Вы уже записаны на курс')
                    : ElevatedButton(
                  onPressed: () async {
                    final userId = context.read<AuthService>().currentUser?.id;
                    if (userId == null) return;
                    await _enrollmentService.enroll(userId, widget.courseId);
                    setState(() => _isEnrolled = true);
                  },
                  child: const Text('Записаться на курс'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}